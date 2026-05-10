using AssetManager.Orm.Dto;
using Microsoft.Data.SqlClient;
using System.Data;

namespace AssetManager.Orm.Dao
{
    public static class QueriesDao
    {
        private const string GetStatsProcedure = "GetStats";

        public static List<AssetStat> GetStats(Database db)
        {
            using SqlCommand command = db.CreateCommand(GetStatsProcedure);
            command.CommandType = CommandType.StoredProcedure;
            using SqlDataReader reader = command.ExecuteReader();

            List<AssetStat> stats = [];
            while (reader.Read())
            {
                stats.Add(new AssetStat
                {
                    AssetId = Convert.ToInt32(reader["asset_id"]),
                    Name = Convert.ToString(reader["name"]) ?? "",
                    UsageCount = Convert.ToInt32(reader["usage_count"])
                });
            }

            return stats;
        }
    }
}
