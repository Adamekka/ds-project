begin transaction;

insert into [Author](author_id, name, email, role, created_at)
values
    (1, 'Jan Novak', 'jan.novak@example.com', '3D Artist', '2025-01-10'),
    (2, 'Petr Svoboda', 'petr.svoboda@example.com', 'Sound Designer', '2025-01-12');

insert into AssetType(asset_type_id, name, description)
values
    (1, '3D model', '3D objekty pro hru'),
    (2, 'Texture', '2D textury a materialy'),
    (3, 'Sound', 'Zvukove efekty a hudba');

insert into [License](license_id, name, license_url, is_commercial, usage_notes)
values
    (1, 'Internal', null, 1, 'Pouze pro interni projekty studia'),
    (2, 'CC-BY 4.0', 'https://creativecommons.org/licenses/by/4.0/', 1, 'Nutno uvest autora'),
    (3, 'Free for non-commercial', null, 0, 'Pouze nekomercni pouziti');

insert into Project(project_id, name, description, status, start_date, end_date)
values
    (1, 'RPG_Prototype', 'Prototyp RPG hry', 'in_development', '2025-02-01', null),
    (2, 'Mobile_Puzzle', 'Casual puzzle hra na mobil', 'planning', '2025-03-01', null),
    (3, 'Released_Demo', 'Vydana ukazka hry', 'released', '2025-01-01', '2025-04-01');

insert into Asset(asset_id, name, asset_type_id, main_author_id, license_id, file_format, size_mb, created_at, is_active, description)
values
    (1, 'Warrior_Model', 1, 1, 1, 'fbx', 12.50, '2025-02-05', 1, 'Low-poly model'),
    (2, 'Menu_Background', 2, 1, 2, 'png', 3.20, '2025-02-07', 1, 'Background pro hlavni menu'),
    (3, 'Sword_Slash_SFX', 3, 2, 1, 'wav', 1.10, '2025-02-09', 1, 'Zvuk seku mecem');

insert into AssetVersion(asset_version_id, asset_id, version_number, file_path, created_at, changelog, is_approved)
values
    (1, 1, 1, '/assets/warrior/warrior_v1.fbx', '2025-02-05', 'Prvni verze modelu', 0),
    (2, 1, 2, '/assets/warrior/warrior_v2_optimized.fbx', '2025-02-10', 'Optimalizace polygonu', 1),
    (3, 2, 1, '/assets/ui/menu_bg_v1.png', '2025-02-07', 'Zakladni pozadi', 1);

insert into AssetProjectUsage(asset_id, project_id, usage_role, added_at, is_active)
values
    (1, 1, 'enemy_model', '2025-02-11', 1),
    (2, 1, 'menu_background', '2025-02-11', 1),
    (3, 1, 'attack_sfx', '2025-02-12', 1);

commit;
go

select * from [Author];
select * from AssetType;
select * from [License];
select * from Project;
select * from Asset;
select * from AssetVersion;
select * from AssetProjectUsage;
