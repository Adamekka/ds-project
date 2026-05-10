create table [Author] (
    author_id int not null primary key,
    name varchar(100) not null,
    email varchar(150) null,
    role varchar(50) null,
    created_at date not null
);
go

create table AssetType (
    asset_type_id int not null primary key,
    name varchar(50) not null,
    description varchar(255) null
);
go

create table [License] (
    license_id int not null primary key,
    name varchar(100) not null,
    license_url varchar(255) null,
    is_commercial bit not null,
    usage_notes varchar(500) null
);
go

create table Project (
    project_id int not null primary key,
    name varchar(100) not null,
    description varchar(500) null,
    status varchar(30) null,
    start_date date null,
    end_date date null
);
go

create table Asset (
    asset_id int not null primary key,
    name varchar(100) not null,
    asset_type_id int not null,
    main_author_id int not null,
    license_id int not null,
    file_format varchar(10) not null,
    size_mb decimal(10, 2) null,
    created_at date not null,
    is_active bit not null,
    description varchar(500) null,
    constraint FK_Asset_AssetType foreign key (asset_type_id) references AssetType(asset_type_id),
    constraint FK_Asset_Author foreign key (main_author_id) references [Author](author_id),
    constraint FK_Asset_License foreign key (license_id) references [License](license_id)
);
go

create table AssetVersion (
    asset_version_id int not null primary key,
    asset_id int not null,
    version_number int not null,
    file_path varchar(255) not null,
    created_at date not null,
    changelog varchar(500) null,
    is_approved bit not null,
    constraint FK_AssetVersion_Asset foreign key (asset_id) references Asset(asset_id),
    constraint UQ_AssetVersion_Asset_Version unique (asset_id, version_number)
);
go

create table AssetProjectUsage (
    asset_id int not null,
    project_id int not null,
    usage_role varchar(100) null,
    added_at date not null,
    is_active bit not null,
    constraint PK_AssetProjectUsage primary key (asset_id, project_id),
    constraint FK_AssetProjectUsage_Asset foreign key (asset_id) references Asset(asset_id),
    constraint FK_AssetProjectUsage_Project foreign key (project_id) references Project(project_id)
);
go
