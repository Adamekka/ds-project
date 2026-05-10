using AssetManager.Orm.Dto;
using Microsoft.Data.SqlClient;
using System.Data;

namespace AssetManager.Orm.Dao
{
    public static class AssetDao
    {
        private const string GetAssetProcedure = "GetAsset";
        private const string FindAssetsProcedure = "FindAssets";
        private const string GetAssetsProcedure = "GetAssets";

        private const string SqlExistsForUpdate = """
        select count(*)
        from Asset with (updlock, holdlock)
        where asset_id = @asset_id
        """;

        private const string SqlInsert = """
        insert into Asset(asset_id, name, asset_type_id, main_author_id, license_id,
                          file_format, size_mb, created_at, is_active, description)
        values(@asset_id, @name, @asset_type_id, @main_author_id, @license_id,
               @file_format, @size_mb, @created_at, @is_active, @description)
        """;

        private const string SqlUpdate = """
        update Asset
        set name = @name,
            license_id = @license_id,
            file_format = @file_format,
            size_mb = @size_mb,
            is_active = @is_active,
            description = @description
        where asset_id = @asset_id
        """;

        public static AssetDetail? GetAsset(Database db, int? assetId, string? name, int? assetTypeId)
        {
            if (assetId is null && string.IsNullOrWhiteSpace(name) && assetTypeId is null)
            {
                return null;
            }

            using SqlCommand command = db.CreateCommand(GetAssetProcedure);
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@asset_id", assetId is null ? DBNull.Value : assetId.Value);
            command.Parameters.AddWithValue("@name", string.IsNullOrWhiteSpace(name) ? DBNull.Value : $"%{name}%");
            command.Parameters.AddWithValue("@asset_type_id", assetTypeId is null ? DBNull.Value : assetTypeId.Value);

            using SqlDataReader reader = command.ExecuteReader();
            if (!reader.Read())
            {
                return null;
            }

            return new AssetDetail
            {
                AssetId = Convert.ToInt32(reader["asset_id"]),
                Name = Convert.ToString(reader["name"]) ?? "",
                AssetType = Convert.ToString(reader["asset_type"]) ?? "",
                AuthorName = Convert.ToString(reader["author_name"]) ?? "",
                LicenseName = Convert.ToString(reader["license_name"]) ?? "",
                FileFormat = Convert.ToString(reader["file_format"]) ?? "",
                SizeMb = reader["size_mb"] == DBNull.Value ? null : Convert.ToDecimal(reader["size_mb"]),
                CreatedAt = Convert.ToDateTime(reader["created_at"]),
                IsActive = Convert.ToBoolean(reader["is_active"]),
                Description = reader["description"] == DBNull.Value ? null : Convert.ToString(reader["description"]),
                ApprovedVersionNumber = reader["approved_version_number"] == DBNull.Value ? null : Convert.ToInt32(reader["approved_version_number"])
            };
        }

        public static List<Asset> FindAssets(Database db, int? assetTypeId, bool onlyCommercial, bool onlyActive, bool onlyApproved)
        {
            using SqlCommand command = db.CreateCommand(FindAssetsProcedure);
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@asset_type_id", assetTypeId is null ? DBNull.Value : assetTypeId.Value);
            command.Parameters.AddWithValue("@only_commercial", onlyCommercial);
            command.Parameters.AddWithValue("@only_active", onlyActive);
            command.Parameters.AddWithValue("@only_approved", onlyApproved);

            using SqlDataReader reader = command.ExecuteReader();
            List<Asset> assets = [];
            while (reader.Read())
            {
                assets.Add(ReadAsset(reader));
            }

            return assets;
        }

        public static List<AssetListItem> GetAssets(Database db)
        {
            using SqlCommand command = db.CreateCommand(GetAssetsProcedure);
            command.CommandType = CommandType.StoredProcedure;
            using SqlDataReader reader = command.ExecuteReader();

            List<AssetListItem> assets = [];
            while (reader.Read())
            {
                assets.Add(new AssetListItem
                {
                    AssetId = Convert.ToInt32(reader["asset_id"]),
                    Name = Convert.ToString(reader["name"]) ?? ""
                });
            }

            return assets;
        }

        public static bool ExistsForUpdate(Database db, int assetId)
        {
            using SqlCommand command = db.CreateCommand(SqlExistsForUpdate);
            command.Parameters.AddWithValue("@asset_id", assetId);

            return Convert.ToInt32(command.ExecuteScalar()) > 0;
        }

        public static void Insert(Database db, Asset asset)
        {
            using SqlCommand command = db.CreateCommand(SqlInsert);
            PrepareAssetCommand(command, asset);
            command.ExecuteNonQuery();
        }

        public static void Update(Database db, Asset asset)
        {
            using SqlCommand command = db.CreateCommand(SqlUpdate);
            PrepareAssetCommand(command, asset);
            command.ExecuteNonQuery();
        }

        private static Asset ReadAsset(SqlDataReader reader)
        {
            return new Asset
            {
                AssetId = Convert.ToInt32(reader["asset_id"]),
                Name = Convert.ToString(reader["name"]) ?? "",
                AssetTypeId = Convert.ToInt32(reader["asset_type_id"]),
                MainAuthorId = Convert.ToInt32(reader["main_author_id"]),
                LicenseId = Convert.ToInt32(reader["license_id"]),
                FileFormat = Convert.ToString(reader["file_format"]) ?? "",
                SizeMb = reader["size_mb"] == DBNull.Value ? null : Convert.ToDecimal(reader["size_mb"]),
                CreatedAt = Convert.ToDateTime(reader["created_at"]),
                IsActive = Convert.ToBoolean(reader["is_active"]),
                Description = reader["description"] == DBNull.Value ? null : Convert.ToString(reader["description"])
            };
        }

        private static void PrepareAssetCommand(SqlCommand command, Asset asset)
        {
            command.Parameters.AddWithValue("@asset_id", asset.AssetId);
            command.Parameters.AddWithValue("@name", asset.Name);
            command.Parameters.AddWithValue("@asset_type_id", asset.AssetTypeId);
            command.Parameters.AddWithValue("@main_author_id", asset.MainAuthorId);
            command.Parameters.AddWithValue("@license_id", asset.LicenseId);
            command.Parameters.AddWithValue("@file_format", asset.FileFormat);
            command.Parameters.AddWithValue("@size_mb", asset.SizeMb is null ? DBNull.Value : asset.SizeMb.Value);
            command.Parameters.AddWithValue("@created_at", asset.CreatedAt);
            command.Parameters.AddWithValue("@is_active", asset.IsActive);
            command.Parameters.AddWithValue("@description", asset.Description is null ? DBNull.Value : asset.Description);
        }
    }
}
