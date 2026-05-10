using System.Data;
using AssetManager.Orm.Dto;
using Microsoft.Data.SqlClient;

namespace AssetManager.Orm.Dao
{
    public static class TransactionsDao
    {
        public static bool AddAsset(Database db, Asset asset)
        {
            try
            {
                db.BeginTransaction();

                using SqlCommand validationCommand = db.CreateCommand("""
                select case when
                    exists(select 1 from AssetType where asset_type_id = @asset_type_id)
                    and exists(select 1 from Author where author_id = @main_author_id)
                    and exists(select 1 from License where license_id = @license_id)
                then 1 else 0 end
                """);
                validationCommand.Parameters.AddWithValue("@asset_type_id", asset.AssetTypeId);
                validationCommand.Parameters.AddWithValue("@main_author_id", asset.MainAuthorId);
                validationCommand.Parameters.AddWithValue("@license_id", asset.LicenseId);

                object? validationValue = validationCommand.ExecuteScalar();
                if (Convert.ToInt32(validationValue) != 1)
                {
                    db.Rollback();
                    return false;
                }

                AssetDao.Insert(db, asset);
                db.Commit();
                return true;
            }
            catch (SqlException)
            {
                db.Rollback();
                return false;
            }
        }

        public static bool AddAssetStoredProcedure(Database db, Asset asset)
        {
            using SqlCommand command = db.CreateCommand("AddAsset");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@p_asset_id", asset.AssetId);
            command.Parameters.AddWithValue("@p_name", asset.Name);
            command.Parameters.AddWithValue("@p_asset_type_id", asset.AssetTypeId);
            command.Parameters.AddWithValue("@p_main_author_id", asset.MainAuthorId);
            command.Parameters.AddWithValue("@p_license_id", asset.LicenseId);
            command.Parameters.AddWithValue("@p_file_format", asset.FileFormat);
            command.Parameters.AddWithValue("@p_size_mb", asset.SizeMb is null ? DBNull.Value : asset.SizeMb.Value);
            command.Parameters.AddWithValue("@p_created_at", asset.CreatedAt);
            command.Parameters.AddWithValue("@p_is_active", asset.IsActive);
            command.Parameters.AddWithValue("@p_description", asset.Description is null ? DBNull.Value : asset.Description);

            SqlParameter ret = new("@p_ret", SqlDbType.Bit)
            {
                Direction = ParameterDirection.Output
            };
            command.Parameters.Add(ret);

            command.ExecuteNonQuery();
            return ret.Value != DBNull.Value && Convert.ToBoolean(ret.Value);
        }

        public static bool AddAssetVersion(Database db, AssetVersion version)
        {
            try
            {
                db.BeginTransaction();

                if (!AssetDao.ExistsForUpdate(db, version.AssetId) ||
                    version.VersionNumber <= 0 ||
                    string.IsNullOrWhiteSpace(version.FilePath))
                {
                    db.Rollback();
                    return false;
                }

                if (AssetVersionDao.Exists(db, version.AssetId, version.VersionNumber))
                {
                    db.Rollback();
                    return false;
                }

                if (version.IsApproved)
                {
                    AssetVersionDao.Update(db, version.AssetId, isApproved: false);
                }

                AssetVersionDao.Insert(db, version);
                db.Commit();
                return true;
            }
            catch (SqlException)
            {
                db.Rollback();
                return false;
            }
        }

        public static bool AddAssetVersionStoredProcedure(Database db, AssetVersion version)
        {
            using SqlCommand command = db.CreateCommand("AddAssetVersion");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@p_asset_version_id", version.AssetVersionId);
            command.Parameters.AddWithValue("@p_asset_id", version.AssetId);
            command.Parameters.AddWithValue("@p_version_number", version.VersionNumber);
            command.Parameters.AddWithValue("@p_file_path", version.FilePath);
            command.Parameters.AddWithValue("@p_created_at", version.CreatedAt);
            command.Parameters.AddWithValue("@p_changelog", version.Changelog is null ? DBNull.Value : version.Changelog);
            command.Parameters.AddWithValue("@p_is_approved", version.IsApproved);

            SqlParameter ret = new("@p_ret", SqlDbType.Bit)
            {
                Direction = ParameterDirection.Output
            };
            command.Parameters.Add(ret);

            command.ExecuteNonQuery();
            return ret.Value != DBNull.Value && Convert.ToBoolean(ret.Value);
        }

        public static bool AddAssetProjectUsage(Database db, AssetProjectUsage usage)
        {
            try
            {
                db.BeginTransaction();

                using SqlCommand validationCommand = db.CreateCommand("""
                select case when p.status = 'released' and l.is_commercial = 0 then 0 else 1 end
                from Asset a
                join License l on l.license_id = a.license_id
                join Project p on p.project_id = @project_id
                where a.asset_id = @asset_id
                """);
                validationCommand.Parameters.AddWithValue("@asset_id", usage.AssetId);
                validationCommand.Parameters.AddWithValue("@project_id", usage.ProjectId);

                object? validationValue = validationCommand.ExecuteScalar();
                if (validationValue is null || validationValue == DBNull.Value || Convert.ToInt32(validationValue) == 0)
                {
                    db.Rollback();
                    return false;
                }

                AssetProjectUsageDao.Insert(db, usage);
                db.Commit();
                return true;
            }
            catch (SqlException)
            {
                db.Rollback();
                return false;
            }
        }

        public static bool AddAssetProjectUsageStoredProcedure(Database db, AssetProjectUsage usage)
        {
            using SqlCommand command = db.CreateCommand("AddAssetProjectUsage");
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@p_asset_id", usage.AssetId);
            command.Parameters.AddWithValue("@p_project_id", usage.ProjectId);
            command.Parameters.AddWithValue("@p_usage_role", usage.UsageRole is null ? DBNull.Value : usage.UsageRole);
            command.Parameters.AddWithValue("@p_added_at", usage.AddedAt);
            command.Parameters.AddWithValue("@p_is_active", usage.IsActive);

            SqlParameter ret = new("@p_ret", SqlDbType.Bit)
            {
                Direction = ParameterDirection.Output
            };
            command.Parameters.Add(ret);

            command.ExecuteNonQuery();
            return ret.Value != DBNull.Value && Convert.ToBoolean(ret.Value);
        }
    }
}
