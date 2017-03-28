/**
 * The PRCT.source_files table will house information on each data-set's corresponding source data file.
 * @primary_key source_file_id INTEGER Utilized in order to uniquely identify each source_files recored.
 * @column filename VARCHAR The filename of the corresponding source file.
 * @column file_mod_date DATETIME The date the file arrived in the landing zone.
 * @column file_size INTEGER The size in bytes of the corresponding source file.
 * @column md5_hash INTEGER The compact digital fingerprint of the corresponding source file.
 * @foreign_key dataset_id INTEGER The unique id of the source file's corresponding dataset.
 */
CREATE TABLE source_files(
  source_file_id INTEGER PRIMARY KEY NOT NULL,
  filename       VARCHAR(100)        NOT NULL,
  file_mod_date  DATETIME            NOT NULL,
  file_size      INTEGER             NOT NULL,
  md5_hash       VARCHAR(500)        NOT NULL,
  dataset_id     INTEGER             NOT NULL,
  FOREIGN KEY(dataset_id) REFERENCES datasets(dataset_id) ON DELETE CASCADE
);