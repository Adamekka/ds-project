namespace AssetManager.Orm.Dto
{
    public sealed class AssetVersion
    {
        public int AssetVersionId { get; set; }
        public int AssetId { get; set; }
        public int VersionNumber { get; set; }
        public string FilePath { get; set; } = "";
        public DateTime CreatedAt { get; set; }
        public string? Changelog { get; set; }
        public bool IsApproved { get; set; }
    }
}
