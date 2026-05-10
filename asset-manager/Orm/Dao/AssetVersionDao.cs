using System.Data;
using AssetManager.Orm.Dto;
using Microsoft.Data.SqlClient;

namespace AssetManager.Orm.Dao
{
    public static class AssetVersionDao
    {
        private const string GetAssetVersionsProcedure = "GetAssetVersions";

        private const string SqlInsert = """
        insert into AssetVersion(asset_version_id, asset_id, version_number, file_path, created_at, changelog, is_approved)
        values(@asset_version_id, @asset_id, @version_number, @file_path, @created_at, @changelog, @is_approved)
        """;

        private const string SqlExists = """
        select count(*)
        from AssetVersion
        where asset_id = @asset_id and version_number = @version_number
        """;

        private const string SqlUpdate = """
        update AssetVersion
        set asset_id = @asset_id,
            version_number = @version_number,
            file_path = @file_path,
            created_at = @created_at,
            changelog = @changelog,
            is_approved = @is_approved
        where asset_version_id = @asset_version_id
        """;

        private const string SqlNextAssetVersionId = """
        select coalesce(max(asset_version_id), 0) + 1
        from AssetVersion
        """;

        private const string SqlNextVersionNumber = """
        select coalesce(max(version_number), 0) + 1
        from AssetVersion
        where asset_id = @asset_id
        """;

        public static List<AssetVersion> GetAssetVersions(Database db, int assetId)
        {
            using SqlCommand command = db.CreateCommand(GetAssetVersionsProcedure);
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@asset_id", assetId);

            using SqlDataReader reader = command.ExecuteReader();
            List<AssetVersion> versions = [];
            while (reader.Read())
            {
                versions.Add(new AssetVersion
                {
                    AssetVersionId = Convert.ToInt32(reader["asset_version_id"]),
                    AssetId = Convert.ToInt32(reader["asset_id"]),
                    VersionNumber = Convert.ToInt32(reader["version_number"]),
                    FilePath = Convert.ToString(reader["file_path"]) ?? "",
                    CreatedAt = Convert.ToDateTime(reader["created_at"]),
                    Changelog = reader["changelog"] == DBNull.Value ? null : Convert.ToString(reader["changelog"]),
                    IsApproved = Convert.ToBoolean(reader["is_approved"])
                });
            }

            return versions;
        }

        public static bool Exists(Database db, int assetId, int versionNumber)
        {
            using SqlCommand command = db.CreateCommand(SqlExists);
            command.Parameters.AddWithValue("@asset_id", assetId);
            command.Parameters.AddWithValue("@version_number", versionNumber);

            return Convert.ToInt32(command.ExecuteScalar()) > 0;
        }

        public static void Update(Database db, AssetVersion version)
        {
            using SqlCommand command = db.CreateCommand(SqlUpdate);
            PrepareAssetVersionCommand(command, version);
            command.ExecuteNonQuery();
        }

        public static void Update(Database db, int assetId, bool isApproved)
        {
            foreach (AssetVersion version in GetAssetVersions(db, assetId))
            {
                version.IsApproved = isApproved;
                Update(db, version);
            }
        }

        public static int NextAssetVersionId(Database db)
        {
            using SqlCommand command = db.CreateCommand(SqlNextAssetVersionId);
            return Convert.ToInt32(command.ExecuteScalar());
        }

        public static int NextVersionNumber(Database db, int assetId)
        {
            using SqlCommand command = db.CreateCommand(SqlNextVersionNumber);
            command.Parameters.AddWithValue("@asset_id", assetId);

            return Convert.ToInt32(command.ExecuteScalar());
        }

        public static void Insert(Database db, AssetVersion version)
        {
            using SqlCommand command = db.CreateCommand(SqlInsert);
            PrepareAssetVersionCommand(command, version);
            command.ExecuteNonQuery();
        }

        private static void PrepareAssetVersionCommand(SqlCommand command, AssetVersion version)
        {
            command.Parameters.AddWithValue("@asset_version_id", version.AssetVersionId);
            command.Parameters.AddWithValue("@asset_id", version.AssetId);
            command.Parameters.AddWithValue("@version_number", version.VersionNumber);
            command.Parameters.AddWithValue("@file_path", version.FilePath);
            command.Parameters.AddWithValue("@created_at", version.CreatedAt);
            command.Parameters.AddWithValue("@changelog", version.Changelog is null ? DBNull.Value : version.Changelog);
            command.Parameters.AddWithValue("@is_approved", version.IsApproved);
        }
    }
}
