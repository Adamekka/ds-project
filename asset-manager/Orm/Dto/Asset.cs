namespace AssetManager.Orm.Dto
{
    public sealed class Asset
    {
        public int AssetId { get; set; }
        public string Name { get; set; } = "";
        public int AssetTypeId { get; set; }
        public int MainAuthorId { get; set; }
        public int LicenseId { get; set; }
        public string FileFormat { get; set; } = "";
        public decimal? SizeMb { get; set; }
        public DateTime CreatedAt { get; set; }
        public bool IsActive { get; set; }
        public string? Description { get; set; }
    }
}
