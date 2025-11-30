CREATE TABLE [Author] (
  [author_id] int PRIMARY KEY,
  [name] varchar(100),
  [email] varchar(150),
  [role] varchar(50),
  [created_at] date
)
GO

CREATE TABLE [AssetType] (
  [asset_type_id] int PRIMARY KEY,
  [name] varchar(50),
  [description] varchar(255)
)
GO

CREATE TABLE [License] (
  [license_id] int PRIMARY KEY,
  [name] varchar(100),
  [license_url] varchar(255),
  [is_commercial] boolean,
  [usage_notes] varchar(500)
)
GO

CREATE TABLE [Project] (
  [project_id] int PRIMARY KEY,
  [name] varchar(100),
  [description] varchar(500),
  [status] varchar(30),
  [start_date] date,
  [end_date] date
)
GO

CREATE TABLE [Asset] (
  [asset_id] int PRIMARY KEY,
  [name] varchar(100),
  [asset_type_id] int,
  [main_author_id] int,
  [license_id] int,
  [file_format] varchar(10),
  [size_mb] decimal(10,2),
  [created_at] date,
  [is_active] boolean,
  [description] varchar(500)
)
GO

CREATE TABLE [AssetVersion] (
  [asset_version_id] int PRIMARY KEY,
  [asset_id] int,
  [version_number] int,
  [file_path] varchar(255),
  [created_at] date,
  [changelog] varchar(500),
  [is_approved] boolean
)
GO

CREATE TABLE [AssetProjectUsage] (
  [asset_id] int,
  [project_id] int,
  [usage_role] varchar(100),
  [added_at] date,
  [is_active] boolean,
  PRIMARY KEY ([asset_id], [project_id])
)
GO

EXEC sp_addextendedproperty
@name = N'Table_Description',
@value = 'Primární klíč je kombinace asset_id + project_id',
@level0type = N'Schema', @level0name = 'dbo',
@level1type = N'Table',  @level1name = 'AssetProjectUsage';
GO

ALTER TABLE [Asset] ADD FOREIGN KEY ([asset_type_id]) REFERENCES [AssetType] ([asset_type_id])
GO

ALTER TABLE [Asset] ADD FOREIGN KEY ([main_author_id]) REFERENCES [Author] ([author_id])
GO

ALTER TABLE [Asset] ADD FOREIGN KEY ([license_id]) REFERENCES [License] ([license_id])
GO

ALTER TABLE [AssetVersion] ADD FOREIGN KEY ([asset_id]) REFERENCES [Asset] ([asset_id])
GO

ALTER TABLE [AssetProjectUsage] ADD FOREIGN KEY ([asset_id]) REFERENCES [Asset] ([asset_id])
GO

ALTER TABLE [AssetProjectUsage] ADD FOREIGN KEY ([project_id]) REFERENCES [Project] ([project_id])
GO
