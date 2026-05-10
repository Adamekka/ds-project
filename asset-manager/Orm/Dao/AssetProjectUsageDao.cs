using AssetManager.Orm.Dto;
using Microsoft.Data.SqlClient;
using System.Data;

namespace AssetManager.Orm.Dao
{
    public static class AssetProjectUsageDao
    {
        private const string GetAssetProjectsProcedure = "GetAssetProjects";

        private const string SqlInsert = """
        insert into AssetProjectUsage(asset_id, project_id, usage_role, added_at, is_active)
        values(@asset_id, @project_id, @usage_role, @added_at, @is_active)
        """;

        public static List<AssetProjectUsage> GetAssetProjects(Database db, int assetId)
        {
            using SqlCommand command = db.CreateCommand(GetAssetProjectsProcedure);
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@asset_id", assetId);

            using SqlDataReader reader = command.ExecuteReader();
            List<AssetProjectUsage> projects = [];
            while (reader.Read())
            {
                projects.Add(new AssetProjectUsage
                {
                    AssetId = Convert.ToInt32(reader["asset_id"]),
                    ProjectId = Convert.ToInt32(reader["project_id"]),
                    UsageRole = reader["usage_role"] == DBNull.Value ? null : Convert.ToString(reader["usage_role"]),
                    AddedAt = Convert.ToDateTime(reader["added_at"]),
                    IsActive = Convert.ToBoolean(reader["is_active"]),
                    ProjectName = Convert.ToString(reader["project_name"]) ?? "",
                    ProjectStatus = reader["project_status"] == DBNull.Value ? null : Convert.ToString(reader["project_status"])
                });
            }

            return projects;
        }

        public static void Insert(Database db, AssetProjectUsage usage)
        {
            using SqlCommand command = db.CreateCommand(SqlInsert);
            PrepareAssetProjectUsageCommand(command, usage);
            command.ExecuteNonQuery();
        }

        private static void PrepareAssetProjectUsageCommand(SqlCommand command, AssetProjectUsage usage)
        {
            command.Parameters.AddWithValue("@asset_id", usage.AssetId);
            command.Parameters.AddWithValue("@project_id", usage.ProjectId);
            command.Parameters.AddWithValue("@usage_role", usage.UsageRole is null ? DBNull.Value : usage.UsageRole);
            command.Parameters.AddWithValue("@added_at", usage.AddedAt);
            command.Parameters.AddWithValue("@is_active", usage.IsActive);
        }
    }
}
