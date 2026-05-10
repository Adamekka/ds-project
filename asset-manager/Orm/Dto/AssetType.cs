namespace AssetManager.Orm.Dto
{
    public sealed class AssetType
    {
        public int AssetTypeId { get; set; }
        public string Name { get; set; } = "";
        public string? Description { get; set; }
    }
}
