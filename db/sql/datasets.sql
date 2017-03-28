/**
 * The PRCT.datasets table will hold information on the datasets that will be updated either via ad-hoc
 * meta-data, or time-stamp trigger. This table will hold the following information:
 * @primary_key dataset_id INTEGER Utilized in order to uniquely identify each dataset record
 * @column dataset_name VARCHAR Name of the dataset as it appears in DOPS
 * @column dataset_string VARCHAR Name of the dataset as it appears within the filename.
 * @column ecl_module VARCHAR The name of the corresponding ECL module
 * @column ecl VARCHAR The ecl code the will be utilize to initialize the corresponding build.
 * @column data_file_count INTEGER The expected number of data files for the dataset.
 * @column rebuild_after INTEGER The number of days after last build to rebuild the dataset if no new source received
 * @column last_workunit VARCHAR The work unit of the previous related build.
 * @column last_wu_start DATETIME The time stamp of when the previous corresponding ECL work-unit was kicked off.
 * @column last_wu_finish DATETIME The time stamp of when the previous corresponding build finished in ECL.
 * @column active BIT Indicate as to whether or not the record is an active.
 * @column add_date DATETIME The time stamp in which the dataset was added to the table.
 * @column mod_date DATETIME The time stamp in which the dataset was last updated.
 */
CREATE TABLE datasets(
  dataset_id      INTEGER PRIMARY KEY NOT NULL,
  dataset_name    VARCHAR(100)        NOT NULL,
  dataset_string  VARCHAR(100)        NOT NULL,
  ecl_module      VARCHAR(100)        NOT NULL,
  ecl             VARCHAR(1000)
  data_file_count INTEGER,
  rebuild_after   INTEGER,
  last_workunit   VARCHAR(100),
  last_wu_start   DATETIME,
  last_wu_finish  DATETIME,
  active          BIT                 NOT NULL,
  add_date        DATETIME,
  mod_date        DATETIME
);

/**
 * When a record is added to PRCT.datasets the field add_date is updated with a time stamp. 
 */
CREATE TRIGGER insert_datasets AFTER INSERT ON datasets
 BEGIN
    UPDATE datasets SET add_date = DATETIME('now', 'localtime') WHERE dataset_id = new.dataset_id;
 END;

/**
 * When a record is updated in PRCT.datasets the field mod_date is updated with a time stamp.
 */
CREATE TRIGGER update_datasets AFTER UPDATE ON datasets
 BEGIN
    UPDATE datasets SET mod_date = DATETIME('now', 'localtime') WHERE dataset_id = old.dataset_id;
 END;
