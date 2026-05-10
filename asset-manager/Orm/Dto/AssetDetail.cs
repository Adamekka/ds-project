namespace AssetManager.Orm.Dto
{
    public sealed class AssetDetail
    {
        public int AssetId { get; set; }
        public string Name { get; set; } = "";
        public string AssetType { get; set; } = "";
        public string AuthorName { get; set; } = "";
        public string LicenseName { get; set; } = "";
        public string FileFormat { get; set; } = "";
        public decimal? SizeMb { get; set; }
        public DateTime CreatedAt { get; set; }
        public bool IsActive { get; set; }
        public string? Description { get; set; }
        public int? ApprovedVersionNumber { get; set; }
    }
}
