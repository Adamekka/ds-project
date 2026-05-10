using AssetManager.Orm.Dto;
using Microsoft.Data.SqlClient;
using System.Data;

namespace AssetManager.Orm.Dao
{
    public static class AssetTypeDao
    {
        private const string GetAssetTypesProcedure = "GetAssetTypes";

        public static List<AssetType> GetAssetTypes(Database db)
        {
            using SqlCommand command = db.CreateCommand(GetAssetTypesProcedure);
            command.CommandType = CommandType.StoredProcedure;
            using SqlDataReader reader = command.ExecuteReader();

            List<AssetType> assetTypes = [];
            while (reader.Read())
            {
                assetTypes.Add(new AssetType
                {
                    AssetTypeId = Convert.ToInt32(reader["asset_type_id"]),
                    Name = Convert.ToString(reader["name"]) ?? "",
                    Description = reader["description"] == DBNull.Value ? null : Convert.ToString(reader["description"])
                });
            }

            return assetTypes;
        }
    }
}
