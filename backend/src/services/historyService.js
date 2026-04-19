const { getDb, save } = require('../db/database');

class HistoryService {
  addRecord(result) {
    const db = getDb();
    const timestamp = new Date().toISOString().replace('T', ' ').substring(0, 19);
    const defects = JSON.stringify(result.defects || { isDamaged: false, isStained: false, isWrinkled: false });
    const position = JSON.stringify(result.position || { isCorrect: true, x: 0, y: 0, deviation: 0 });

    db.run(
      `INSERT INTO detection_records
        (timestamp, product_model, grade, energy_param, standby_power, is_data_match, defects, position, is_pass, has_defect, grade_method, label_confidence)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        timestamp,
        result.productModel || '-',
        result.grade || 0,
        result.energyParam != null ? String(result.energyParam) : '未识别',
        result.standbyPower != null ? String(result.standbyPower) : '未识别',
        (result.labelFound || false) ? 1 : 0,
        defects,
        position,
        (result.isPass || false) ? 1 : 0,
        (result.hasDefect || false) ? 1 : 0,
        result.gradeMethod || null,
        result.labelConfidence || null,
      ]
    );

    const idRs = db.exec('SELECT last_insert_rowid()');
    const id = idRs[0] ? idRs[0].values[0][0] : 0;
    save();

    return {
      id: String(id),
      timestamp,
      productModel: result.productModel || '-',
      grade: result.grade || 0,
      energyParam: result.energyParam != null ? String(result.energyParam) : '未识别',
      standbyPower: result.standbyPower != null ? String(result.standbyPower) : '未识别',
      isDataMatch: result.labelFound || false,
      defects: result.defects || { isDamaged: false, isStained: false, isWrinkled: false },
      position: result.position || { isCorrect: true, x: 0, y: 0, deviation: 0 },
      isPass: result.isPass || false,
      hasDefect: result.hasDefect || false,
      gradeMethod: result.gradeMethod || null,
      labelConfidence: result.labelConfidence || null,
    };
  }

  getDetectionRecords(filters = {}) {
    const db = getDb();
    let sql = 'SELECT * FROM detection_records WHERE 1=1';
    const params = [];

    if (filters.productModel) {
      sql += ' AND product_model LIKE ?';
      params.push(`%${filters.productModel}%`);
    }
    if (filters.startDate) {
      sql += ' AND timestamp >= ?';
      params.push(filters.startDate);
    }
    if (filters.endDate) {
      sql += ' AND timestamp <= ?';
      params.push(filters.endDate + ' 23:59:59');
    }
    if (filters.status === 'pass') {
      sql += ' AND is_pass = 1';
    } else if (filters.status === 'fail') {
      sql += ' AND is_pass = 0';
    }

    sql += ' ORDER BY id DESC';

    const stmt = db.prepare(sql);
    stmt.bind(params);
    const records = [];
    while (stmt.step()) {
      const row = stmt.getAsObject();
      records.push(this._rowToRecord(row));
    }
    stmt.free();
    return records;
  }

  getDetectionRecordById(id) {
    const db = getDb();
    const stmt = db.prepare('SELECT * FROM detection_records WHERE id = ?');
    stmt.bind([id]);
    if (stmt.step()) {
      const record = this._rowToRecord(stmt.getAsObject());
      stmt.free();
      return record;
    }
    stmt.free();
    throw new Error('记录未找到');
  }

  deleteRecord(id) {
    const db = getDb();
    db.run('DELETE FROM detection_records WHERE id = ?', [id]);
    save();
  }

  deleteAllRecords() {
    const db = getDb();
    db.run('DELETE FROM detection_records');
    save();
  }

  getStats() {
    const db = getDb();
    const totalRs = db.exec('SELECT COUNT(*) as cnt FROM detection_records');
    const total = totalRs[0] ? totalRs[0].values[0][0] : 0;

    const passRs = db.exec('SELECT COUNT(*) FROM detection_records WHERE is_pass = 1');
    const passCount = passRs[0] ? passRs[0].values[0][0] : 0;
    const failCount = total - passCount;

    const damagedRs = db.exec("SELECT COUNT(*) FROM detection_records WHERE defects LIKE '%isDamaged\":true%'");
    const damaged = damagedRs[0] ? damagedRs[0].values[0][0] : 0;

    const stainedRs = db.exec("SELECT COUNT(*) FROM detection_records WHERE defects LIKE '%isStained\":true%'");
    const stained = stainedRs[0] ? stainedRs[0].values[0][0] : 0;

    const wrinkledRs = db.exec("SELECT COUNT(*) FROM detection_records WHERE defects LIKE '%isWrinkled\":true%'");
    const wrinkled = wrinkledRs[0] ? wrinkledRs[0].values[0][0] : 0;

    const devRs = db.exec("SELECT position FROM detection_records");
    const deviations = [];
    if (devRs[0]) {
      for (const row of devRs[0].values) {
        try {
          const pos = JSON.parse(row[0]);
          if (pos.deviation > 0) deviations.push(pos.deviation);
        } catch (e) { /* skip */ }
      }
    }

    const avgDev = deviations.length > 0
      ? (deviations.reduce((a, b) => a + b, 0) / deviations.length).toFixed(2)
      : '0';
    const maxDev = deviations.length > 0 ? Math.max(...deviations).toFixed(2) : '0';
    const minDev = deviations.length > 0 ? Math.min(...deviations).toFixed(2) : '0';

    return {
      total, passCount, failCount,
      passRate: total > 0 ? Math.round(passCount / total * 100) : 0,
      damaged, stained, wrinkled,
      avgDev, maxDev, minDev,
    };
  }

  exportDetectionRecords(filters) {
    const records = this.getDetectionRecords(filters);
    let csv = '\uFEFFID,时间,产品型号,能效等级,能效参数,待机功率,数据匹配,破损,污渍,褶皱,位置正确,偏差,检测结果\n';
    records.forEach(r => {
      csv += [
        r.id, r.timestamp, r.productModel,
        r.grade ? `${r.grade}级` : '未识别',
        r.energyParam, r.standbyPower,
        r.isDataMatch ? '是' : '否',
        r.defects.isDamaged ? '是' : '否',
        r.defects.isStained ? '是' : '否',
        r.defects.isWrinkled ? '是' : '否',
        r.position.isCorrect ? '是' : '否',
        r.position.deviation,
        r.isPass ? '通过' : '失败',
      ].join(',') + '\n';
    });
    return csv;
  }

  _rowToRecord(row) {
    return {
      id: String(row.id),
      timestamp: row.timestamp,
      productModel: row.product_model,
      grade: row.grade,
      energyParam: row.energy_param,
      standbyPower: row.standby_power,
      isDataMatch: !!row.is_data_match,
      defects: typeof row.defects === 'string' ? JSON.parse(row.defects) : row.defects,
      position: typeof row.position === 'string' ? JSON.parse(row.position) : row.position,
      isPass: !!row.is_pass,
      hasDefect: !!row.has_defect,
      gradeMethod: row.grade_method,
      labelConfidence: row.label_confidence,
    };
  }
}

module.exports = new HistoryService();
