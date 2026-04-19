const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');
const http = require('http');
const historyService = require('./historyService');
const { getDb, save } = require('../db/database');

// 配置 - 根据实际环境修改
const CONFIG = {
  // conda dl_train 环境的 Python 路径
  pythonPath: 'C:\\Users\\22069\\.conda\\envs\\dl_train\\python.exe',
  // 检测脚本路径（回退用）
  detectScript: path.join(__dirname, '..', 'python', 'detect_api.py'),
  // 常驻检测服务地址
  detectServerUrl: 'http://localhost:5001',
  // 临时图片保存目录
  uploadDir: path.join(__dirname, '..', '..', 'uploads'),
};

// 确保上传目录存在
if (!fs.existsSync(CONFIG.uploadDir)) {
  fs.mkdirSync(CONFIG.uploadDir, { recursive: true });
}

class DetectionService {
  constructor() {
    this.detectionResult = {
      grade: null,
      gradeMethod: null,
      gradeConfidence: null,
      energyParam: null,
      standbyPower: null,
      isPass: false,
      defects: { isDamaged: false, isStained: false, isWrinkled: false },
      position: { isCorrect: true, x: 0, y: 0, deviation: 0 },
      labelFound: false,
      detections: [],
    };
    this.isDetecting = false;
  }

  getDetectionResult() {
    try {
      const db = getDb();
      const stmt = db.prepare('SELECT * FROM detection_records ORDER BY id DESC LIMIT 1');
      if (stmt.step()) {
        const row = stmt.getAsObject();
        stmt.free();
        return {
          success: true,
          grade: row.grade || null,
          gradeMethod: row.grade_method,
          gradeConfidence: row.label_confidence,
          energyParam: row.energy_param !== '未识别' ? parseFloat(row.energy_param) : null,
          standbyPower: row.standby_power !== '未识别' ? parseFloat(row.standby_power) : null,
          defects: typeof row.defects === 'string' ? JSON.parse(row.defects) : row.defects,
          position: typeof row.position === 'string' ? JSON.parse(row.position) : row.position,
          isPass: !!row.is_pass,
          labelFound: !!row.is_data_match,
          hasDefect: !!row.has_defect,
        };
      }
      stmt.free();
    } catch (e) { /* 数据库未就绪时回退 */ }
    return this.detectionResult;
  }

  startDetection() {
    this.isDetecting = true;
    console.log('检测已开始');
  }

  stopDetection() {
    this.isDetecting = false;
    console.log('检测已停止');
  }

  importMLResult(result) {
    this.detectionResult = result;
    console.log('机器学习结果导入成功');
  }

  /**
   * 分析图片 - 调用 Python 检测脚本
   * @param {string} imageBase64 - Base64 编码的图片数据
   * @returns {Promise<Object>} 检测结果
   */
  async analyzeImage(imageBase64) {
    // 解码 base64 并保存为临时文件
    const matches = imageBase64.match(/^data:image\/(\w+);base64,(.+)$/);
    const ext = matches ? matches[1] : 'jpg';
    const base64Data = matches ? matches[2] : imageBase64;

    const tempFileName = `upload_${Date.now()}.${ext}`;
    const tempFilePath = path.join(CONFIG.uploadDir, tempFileName);

    try {
      // 保存图片到临时文件
      fs.writeFileSync(tempFilePath, Buffer.from(base64Data, 'base64'));
      console.log(`图片已保存: ${tempFilePath}`);

      // 调用 Python 检测脚本
      const result = await this.runDetection(tempFilePath);
      return result;
    } catch (error) {
      console.error('图片分析失败:', error);
      throw error;
    } finally {
      // 清理临时文件
      try {
        if (fs.existsSync(tempFilePath)) {
          fs.unlinkSync(tempFilePath);
        }
      } catch (e) {
        console.warn('清理临时文件失败:', e.message);
      }
    }
  }

  /**
   * 运行检测 - 优先使用常驻服务（模型已加载），失败时回退到 spawn
   */
  runDetection(imagePath) {
    return this._runDetectionServer(imagePath)
      .catch(() => this._runDetectionSpawn(imagePath));
  }

  /**
   * 通过常驻检测服务（detect_server.py）进行检测
   */
  _runDetectionServer(imagePath) {
    return new Promise((resolve, reject) => {
      const postData = JSON.stringify({ image_path: imagePath });

      const url = new URL(`${CONFIG.detectServerUrl}/detect`);
      const options = {
        hostname: url.hostname,
        port: url.port,
        path: url.pathname,
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Content-Length': Buffer.byteLength(postData),
        },
        timeout: 30000,
      };

      const req = http.request(options, (res) => {
        let data = '';
        res.on('data', (chunk) => { data += chunk; });
        res.on('end', () => {
          try {
            const result = JSON.parse(data);
            this.detectionResult = result;
            if (result.success) {
              historyService.addRecord(result);
              console.log(`检测完成（常驻服务，${result.detectionTime || '?'}s），已存入历史记录`);
            }
            resolve(result);
          } catch (e) {
            console.error('解析常驻服务响应失败:', data.substring(0, 200));
            reject(new Error('常驻服务响应解析失败'));
          }
        });
      });

      req.on('error', (err) => {
        console.log('常驻检测服务不可用，回退到 spawn 模式');
        reject(err);
      });

      req.on('timeout', () => {
        req.destroy();
        reject(new Error('常驻服务超时'));
      });

      req.write(postData);
      req.end();
    });
  }

  /**
   * 回退方式：spawn 新的 Python 进程（每次重新加载模型，较慢）
   */
  _runDetectionSpawn(imagePath) {
    return new Promise((resolve, reject) => {
      const python = spawn(CONFIG.pythonPath, [CONFIG.detectScript, imagePath]);

      let stdout = '';
      let stderr = '';

      python.stdout.on('data', (data) => {
        stdout += data.toString();
      });

      python.stderr.on('data', (data) => {
        stderr += data.toString();
        console.log(`Python stderr: ${data}`);
      });

      python.on('close', (code) => {
        if (code !== 0) {
          console.error(`Python 进程退出码: ${code}`);
          console.error(`stderr: ${stderr}`);
          reject(new Error(`检测失败 (退出码: ${code}): ${stderr.substring(0, 200)}`));
          return;
        }

        try {
          const lines = stdout.trim().split('\n');
          const jsonLine = lines[lines.length - 1];
          const result = JSON.parse(jsonLine);

          this.detectionResult = result;
          if (result.success) {
            historyService.addRecord(result);
            console.log('检测完成（spawn 模式），已存入历史记录');
          }
          resolve(result);
        } catch (e) {
          console.error('解析 Python 输出失败:', stdout);
          reject(new Error('检测结果解析失败'));
        }
      });

      python.on('error', (err) => {
        console.error('启动 Python 进程失败:', err);
        reject(new Error(`启动检测引擎失败: ${err.message}`));
      });

      setTimeout(() => {
        python.kill();
        reject(new Error('检测超时'));
      }, 60000);
    });
  }
}

module.exports = new DetectionService();
