-- Autoři
INSERT INTO Author (author_id, name, email, role, created_at)
VALUES
(1, 'Jan Novák', 'jan.novak@example.com', '3D Artist', '2025-01-10'),
(2, 'Petr Svoboda', 'petr.svoboda@example.com', 'Sound Designer', '2025-01-12');

-- Typy assetů
INSERT INTO AssetType (asset_type_id, name, description)
VALUES
(1, '3D model', '3D objekty pro hru'),
(2, 'Texture', '2D textury a materiály'),
(3, 'Sound', 'Zvukové efekty a hudba');

-- Licence
INSERT INTO License (license_id, name, license_url, is_commercial, usage_notes)
VALUES
(1, 'Internal', NULL, TRUE, 'Pouze pro interní projekty studia'),
(2, 'CC-BY 4.0', 'https://creativecommons.org/licenses/by/4.0/', TRUE, 'Nutno uvést autora'),
(3, 'Free for non-commercial', NULL, FALSE, 'Pouze nekomerční použití');

-- Projekty
INSERT INTO Project (project_id, name, description, status, start_date)
VALUES
(1, 'RPG_Prototype', 'Prototyp RPG hry', 'in_development', '2025-02-01'),
(2, 'Mobile_Puzzle', 'Casual puzzle hra na mobil', 'planning', '2025-03-01');

-- Assety
INSERT INTO Asset (asset_id, name, asset_type_id, main_author_id, license_id,
                   file_format, size_mb, created_at, is_active, description)
VALUES
(1, 'Warrior_Model', 1, 1, 1, 'fbx', 12.50, '2025-02-05', TRUE, 'Low-poly model'),
(2, 'Menu_Background', 2, 1, 2, 'png', 3.20, '2025-02-07', TRUE, 'Background pro hlavní menu'),
(3, 'Sword_Slash_SFX', 3, 2, 1, 'wav', 1.10, '2025-02-09', TRUE, 'Zvuk seku mečem');

-- Verze assetů
INSERT INTO AssetVersion (asset_version_id, asset_id, version_number,
                          file_path, created_at, changelog, is_approved)
VALUES
(1, 1, 1, '/assets/warrior/warrior_v1.fbx', '2025-02-05', 'První verze modelu', TRUE),
(2, 1, 2, '/assets/warrior/warrior_v2_optimized.fbx', '2025-02-10', 'Optimalizace polygonů', TRUE),
(3, 2, 1, '/assets/ui/menu_bg_v1.png', '2025-02-07', 'Základní pozadí', TRUE);

-- Použití assetů v projektech
INSERT INTO AssetProjectUsage (asset_id, project_id, usage_role, added_at, is_active)
VALUES
(1, 1, 'enemy_model', '2025-02-11', TRUE),
(2, 1, 'menu_background', '2025-02-11', TRUE),
(3, 1, 'attack_sfx', '2025-02-12', TRUE);
