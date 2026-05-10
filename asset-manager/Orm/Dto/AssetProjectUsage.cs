namespace AssetManager.Orm.Dto
{
    public sealed class AssetProjectUsage
    {
        public int AssetId { get; set; }
        public int ProjectId { get; set; }
        public string? UsageRole { get; set; }
        public DateTime AddedAt { get; set; }
        public bool IsActive { get; set; }
        public string ProjectName { get; set; } = "";
        public string? ProjectStatus { get; set; }
    }
}
