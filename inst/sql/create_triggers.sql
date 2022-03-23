CREATE OR REPLACE FUNCTION timeseries.prevent_delete_default_dataset()
RETURNS TRIGGER AS
$$
BEGIN
  IF OLD.set_id = 'default' THEN
    RAISE EXCEPTION 'Can not delete the default dataset.' USING ERRCODE='09000';
  END IF;

  RETURN OLD;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER
SET search_path = timeseries, pg_temp;

DROP TRIGGER IF EXISTS no_delete_default_dataset ON timeseries.datasets;
CREATE TRIGGER no_delete_default_dataset
BEFORE DELETE
ON timeseries.datasets
FOR EACH ROW
EXECUTE PROCEDURE timeseries.prevent_delete_default_dataset();

CREATE OR REPLACE FUNCTION timeseries.ensure_access_level_is_role()
RETURNS TRIGGER AS
$$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_catalog.pg_roles
    WHERE rolname = NEW.role
  ) THEN
    RAISE EXCEPTION 'Role % does not exist so it can not be an access level.',
    NEW.role USING ERRCODE='09000';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER
SET search_path = timeseries, pg_temp;

DROP TRIGGER IF EXISTS access_level_role_check ON timeseries.access_levels;
CREATE TRIGGER access_level_role_check
BEFORE INSERT OR UPDATE
ON timeseries.access_levels
FOR EACH ROW
EXECUTE PROCEDURE timeseries.ensure_access_level_is_role();

CREATE OR REPLACE FUNCTION timeseries.prevent_delete_default_access_level()
RETURNS TRIGGER AS
$$
BEGIN
  IF TG_OP = 'DELETE' THEN
    IF OLD.is_default THEN
      RAISE EXCEPTION 'Role % is the default access level. Please assign a different default before deleting.',
      OLD.role USING ERRCODE='09000';
    END IF;
  END IF;

  RETURN OLD;
END;
$$ LANGUAGE PLPGSQL
SECURITY DEFINER
SET search_path = timeseries, pg_temp;

DROP TRIGGER IF EXISTS access_level_no_delete_default ON timeseries.access_levels;
CREATE TRIGGER access_level_no_delete_default
BEFORE DELETE
ON timeseries.access_levels
FOR EACH ROW
EXECUTE PROCEDURE timeseries.prevent_delete_default_access_level();
