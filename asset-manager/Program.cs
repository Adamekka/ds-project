using AssetManager.Orm;
using AssetManager.Orm.Dao;
using AssetManager.Orm.Dto;
using Microsoft.Data.SqlClient;

const string connectionString = "Server=localhost,1433;Database=AssetManager;User Id=sa;Password=AssetManager123!;TrustServerCertificate=True;Encrypt=False;";
const string masterConnectionString = "Server=localhost,1433;Database=master;User Id=sa;Password=AssetManager123!;TrustServerCertificate=True;Encrypt=False;";

EnsureLocalDatabase();

using Database db = new(connectionString);
db.Open();

List<AssetManager.Orm.Dto.AssetType> assetTypes = AssetTypeDao.GetAssetTypes(db);
Console.WriteLine($"Asset types: {assetTypes.Count}");

const int demoAssetId = 1;
int nextAssetVersionId = AssetVersionDao.NextAssetVersionId(db);
int nextVersionNumber = AssetVersionDao.NextVersionNumber(db, demoAssetId);

AssetVersion csharpVersion = new()
{
    AssetVersionId = nextAssetVersionId,
    AssetId = demoAssetId,
    VersionNumber = nextVersionNumber,
    FilePath = $"/assets/warrior/warrior_v{nextVersionNumber}_csharp.fbx",
    CreatedAt = DateTime.Today,
    Changelog = "C# transaction",
    IsApproved = true
};
bool csharpVersionAdded = TransactionsDao.AddAssetVersion(db, csharpVersion);
Console.WriteLine($"AddAssetVersion C#: {csharpVersionAdded}");

AssetVersion sqlVersion = new()
{
    AssetVersionId = nextAssetVersionId + 1,
    AssetId = demoAssetId,
    VersionNumber = nextVersionNumber + 1,
    FilePath = $"/assets/warrior/warrior_v{nextVersionNumber + 1}_sql.fbx",
    CreatedAt = DateTime.Today,
    Changelog = "SQL stored procedure",
    IsApproved = true
};
bool sqlVersionAdded = TransactionsDao.AddAssetVersionStoredProcedure(db, sqlVersion);
Console.WriteLine($"AddAssetVersion SQL: {sqlVersionAdded}");

AssetManager.Orm.Dto.AssetDetail? asset = AssetDao.GetAsset(db, assetId: demoAssetId, name: null, assetTypeId: null);
if (asset is not null)
{
    Console.WriteLine($"Asset: {asset.Name}, approved version: {asset.ApprovedVersionNumber?.ToString() ?? "none"}");
}

Console.WriteLine($"Asset versions: {AssetVersionDao.GetAssetVersions(db, assetId: demoAssetId).Count}");
Console.WriteLine($"Asset projects: {AssetProjectUsageDao.GetAssetProjects(db, assetId: demoAssetId).Count}");
Console.WriteLine($"Active assets: {AssetDao.FindAssets(db, assetTypeId: null, onlyCommercial: false, onlyActive: true, onlyApproved: false).Count}");
Console.WriteLine($"Stats rows: {QueriesDao.GetStats(db).Count}");

void EnsureLocalDatabase()
{
    using SqlConnection masterConnection = OpenWithRetry(masterConnectionString);
    using (SqlCommand command = masterConnection.CreateCommand())
    {
        command.CommandText = "if db_id('AssetManager') is null create database AssetManager";
        command.ExecuteNonQuery();
    }

    using SqlConnection appConnection = OpenWithRetry(connectionString);
    if (!SchemaExists(appConnection))
    {
        ExecuteSqlFile(appConnection, "create.sql");
        ExecuteSqlFile(appConnection, "init.sql");
    }

    ExecuteSqlFile(appConnection, "QueryProcedures.sql");
    ExecuteSqlFile(appConnection, "AddAsset.sql");
    ExecuteSqlFile(appConnection, "AddAssetVersion.sql");
    ExecuteSqlFile(appConnection, "AddAssetProjectUsage.sql");
    ExecuteSqlFile(appConnection, "triggers.sql");
}

SqlConnection OpenWithRetry(string localConnectionString)
{
    for (int attempt = 1; attempt <= 30; attempt++)
    {
        try
        {
            SqlConnection connection = new(localConnectionString);
            connection.Open();
            return connection;
        }
        catch (SqlException) when (attempt < 30)
        {
            Thread.Sleep(TimeSpan.FromSeconds(2));
        }
    }

    SqlConnection finalConnection = new(localConnectionString);
    finalConnection.Open();
    return finalConnection;
}

bool SchemaExists(SqlConnection connection)
{
    using SqlCommand command = connection.CreateCommand();
    command.CommandText = "select object_id('dbo.Asset')";
    return command.ExecuteScalar() is not DBNull and not null;
}

void ExecuteSqlFile(SqlConnection connection, string fileName)
{
    string sqlPath = ResolveSqlPath(fileName);
    List<string> batches = [];
    List<string> currentBatch = [];

    foreach (string line in File.ReadAllLines(sqlPath))
    {
        if (line.Trim().Equals("go", StringComparison.OrdinalIgnoreCase))
        {
            if (currentBatch.Count > 0)
            {
                batches.Add(string.Join(Environment.NewLine, currentBatch));
                currentBatch.Clear();
            }
        }
        else
        {
            currentBatch.Add(line);
        }
    }

    if (currentBatch.Count > 0)
    {
        batches.Add(string.Join(Environment.NewLine, currentBatch));
    }

    foreach (string batch in batches)
    {
        if (string.IsNullOrWhiteSpace(batch))
        {
            continue;
        }

        using SqlCommand command = connection.CreateCommand();
        command.CommandText = batch;
        command.ExecuteNonQuery();
    }
}

string ResolveSqlPath(string fileName)
{
    string[] candidates =
    [
        Path.Combine(AppContext.BaseDirectory, "Sql", fileName),
        Path.Combine(Directory.GetCurrentDirectory(), "Sql", fileName),
        Path.Combine(Directory.GetCurrentDirectory(), "asset-manager", "Sql", fileName)
    ];

    foreach (string candidate in candidates)
    {
        if (File.Exists(candidate))
        {
            return candidate;
        }
    }

    throw new FileNotFoundException($"Could not find SQL file {fileName}.", fileName);
}
