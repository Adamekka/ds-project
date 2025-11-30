#import "@preview/ilm:1.4.2": *

#set text(lang: "cs")

#show: ilm.with(
  title: "DS1 Projekt",
  author: "Adam Cvikl (CVI0014)",
  date: datetime(year: 2025, month: 11, day: 17),
  date-format: "[day padding:none].[month padding:zero].[year repr:full]",
  abstract: "Asset Manager - správa assetů pro herní vývoj",
  figure-index: (enabled: true),
  table-index: (enabled: true),
  listing-index: (enabled: true),
)

= Relační datový model

#figure(image("assets/rm.png"))

= Popis tabulek databáze

== Přehled tabulek

#table(
  columns: (auto, 3fr),
  [*Tabulka*], [*Popis*],
  [`Author`], [Autoři (tvůrci assetů, např. 3D artist, sound designer).],
  [`AssetType`], [Typy assetů (3D model, textura, zvuk, UI ikona, …).],
  [`License`], [Licenční podmínky použití assetů (MIT, CC-BY, interní, …).],
  [`Project`], [Herní projekty, ve kterých se assety používají.],
  [`Asset`], [Logické assety (např. konkrétní model či textura) bez ohledu na verzi.],
  [`AssetVersion`], [Konkrétní verze jednotlivých assetů (v1, v2, optimalizace, …).],
  [`AssetProjectUsage`], [Použití assetů v projektech (M:N vazba Asset ↔ Project).],
)

== Tabulka `Author`

Tabulka `Author` eviduje tvůrce assetů (grafiky, zvukaře, programátory, …).

#table(
  columns: (auto, auto, auto, 3fr),
  [*Sloupec*], [*Typ*], [*Povinný*], [*Popis*],
  [`author_id`], [int], [ano], [Primární klíč autora.],
  [`name`], [varchar(100)], [ano], [Jméno a příjmení autora.],
  [`email`], [varchar(150)], [ne], [Kontaktní e-mail autora.],
  [`role`], [varchar(50)], [ne], [Role autora, např. „3D Artist“, „Sound Designer“.],
  [`created_at`], [date], [ano], [Datum založení záznamu autora v systému.],
)

== Tabulka `AssetType`

Tabulka `AssetType` popisuje typy assetů (modely, textury, zvuky, …).

#table(
  columns: (auto, auto, auto, 3fr),
  [*Sloupec*], [*Typ*], [*Povinný*], [*Popis*],
  [`asset_type_id`], [int], [ano], [Primární klíč typu assetu.],
  [`name`], [varchar(50)], [ano], [Název typu assetu, např. „3D model“, „Texture“, „Sound“.],
  [`description`], [varchar(255)], [ne], [Podrobnější textový popis typu assetu.],
)

== Tabulka `License`

Tabulka `License` obsahuje licenční podmínky jednotlivých assetů.

#table(
  columns: (auto, auto, auto, 3fr),
  [*Sloupec*], [*Typ*], [*Povinný*], [*Popis*],
  [`license_id`], [int], [ano], [Primární klíč licence.],
  [`name`], [varchar(100)], [ano], [Název licence, např. „MIT“, „CC-BY 4.0“, „Internal“.],
  [`license_url`], [varchar(255)], [ne], [Odkaz na plné znění licence (pokud existuje).],
  [`is_commercial`], [boolean], [ano], [Informace, zda je licence použitelná v komerčních projektech.],
  [`usage_notes`], [varchar(500)], [ne], [Stručné shrnutí podmínek použití nebo omezení licence.],
)

== Tabulka `Project`

Tabulka `Project` reprezentuje herní projekty, ve kterých jsou assety použity.

#table(
  columns: (auto, auto, auto, 3fr),
  [*Sloupec*], [*Typ*], [*Povinný*], [*Popis*],
  [`project_id`], [int], [ano], [Primární klíč projektu.],
  [`name`], [varchar(100)], [ano], [Název herního projektu.],
  [`description`], [varchar(500)], [ne], [Stručný popis projektu.],
  [`status`], [varchar(30)], [ne], [Stav projektu, např. „in_development“, „released“, „planning“.],
  [`start_date`], [date], [ne], [Datum začátku vývoje projektu.],
  [`end_date`], [date], [ne], [Datum ukončení vývoje projektu (pokud je k dispozici).],
)

== Tabulka `Asset`

Tabulka `Asset` reprezentuje logické assety (např. model „Warrior_Model“), bez ohledu na konkrétní verzi souboru.

#table(
  columns: (auto, auto, auto, 3fr),
  [*Sloupec*], [*Typ*], [*Povinný*], [*Popis*],
  [`asset_id`], [int], [ano], [Primární klíč assetu.],
  [`name`], [varchar(100)], [ano], [Název assetu, např. „Warrior_Model“.],
  [`asset_type_id`], [int], [ano], [Cizí klíč na `AssetType`, určuje typ assetu.],
  [`main_author_id`], [int], [ano], [Cizí klíč na `Author`, hlavní autor assetu.],
  [`license_id`], [int], [ano], [Cizí klíč na `License`, určuje licenci assetu.],
  [`file_format`], [varchar(10)], [ano], [Formát souboru, např. „fbx“, „png“, „wav“.],
  [`size_mb`], [decimal(10,2)], [ne], [Velikost assetu v megabajtech.],
  [`created_at`], [date], [ano], [Datum založení assetu v systému.],
  [`is_active`], [boolean], [ano], [Indikace, zda je asset aktivně používán.],
  [`description`], [varchar(500)], [ne], [Textový popis assetu, účel, poznámky.],
)

== Tabulka `AssetVersion`

Tabulka `AssetVersion` reprezentuje jednotlivé verze assetů (v1, v2, optimalizovaná verze, …).

#table(
  columns: (auto, auto, auto, 3fr),
  [*Sloupec*], [*Typ*], [*Povinný*], [*Popis*],
  [`asset_version_id`], [int], [ano], [Primární klíč verze assetu.],
  [`asset_id`], [int], [ano], [Cizí klíč na `Asset`, ke kterému verze patří.],
  [`version_number`], [int], [ano], [Číselné označení verze (1, 2, 3, …).],
  [`file_path`], [varchar(255)], [ano], [Cesta k souboru verze assetu v úložišti.],
  [`created_at`], [date], [ano], [Datum vytvoření dané verze assetu.],
  [`changelog`], [varchar(500)], [ne], [Stručný popis změn oproti předchozí verzi.],
  [`is_approved`], [boolean], [ano], [Indikace, zda je verze schválená pro použití v projektech.],
)

== Tabulka `AssetProjectUsage`

Tabulka `AssetProjectUsage` popisuje použití assetů v konkrétních projektech (M:N vazba mezi `Asset` a `Project`).

#table(
  columns: (auto, auto, auto, 3fr),
  [*Sloupec*], [*Typ*], [*Povinný*], [*Popis*],
  [`asset_id`], [int], [ano], [Cizí klíč na `Asset`. Součást složeného primárního klíče.],
  [`project_id`], [int], [ano], [Cizí klíč na `Project`. Součást složeného primárního klíče.],
  [`usage_role`], [varchar(100)], [ne], [Popis role assetu v projektu, např. „enemy_model“, „menu_background“.],
  [`added_at`], [date], [ano], [Datum přidání assetu do projektu.],
  [`is_active`], [boolean], [ano], [Indikace, zda je použití assetu v projektu stále aktivní.],
)
