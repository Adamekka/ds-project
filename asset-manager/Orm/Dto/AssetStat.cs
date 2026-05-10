namespace AssetManager.Orm.Dto
{
    public sealed class AssetStat
    {
        public int AssetId { get; set; }
        public string Name { get; set; } = "";
        public int UsageCount { get; set; }
    }
}
