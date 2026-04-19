#import "@preview/ilm:1.4.2": *

#set text(lang: "cs")

#show: ilm.with(
  title: "Projekt správy assetů DS II",
  author: "Adam Cvikl (CVI0014)",
  date: datetime(year: 2026, month: 4, day: 19),
  date-format: "[day padding:none].[month padding:zero].[year repr:full]",
  abstract: "Asset Manager - správa assetů pro herní vývoj.",
  figure-index: (enabled: true),
  table-index: (enabled: true),
  listing-index: (enabled: true),
)

= Specifikace programu

Primární úlohou programu je evidovat digitální assety používané při vývoji her a spravovat jejich životní cyklus od prvního vytvoření až po nasazení do konkrétního projektu. Systém umožňuje evidovat autory assetů, jejich typy, licenční podmínky, samotné assety, jednotlivé verze assetů a jejich použití v herních projektech.

U každého assetu se evidují základní informace, hlavní autor, licence, formát souboru, velikost, datum založení a aktivní stav. Součástí systému je také správa schválených verzí assetů a přehled projektů, ve kterých je asset použit. Důležitou funkcí je i filtrování assetů podle typu a licenčních omezení a zjištění, zda je možné daný asset bezpečně použít v konkrétním projektu.

= Relační datový model

#figure(
  image("assets/rm.png"),
  caption: [Relační datový model systému správy assetů.],
)

= Formulář

Hlavní obrazovka aplikace vychází stejnou logikou z referenčního DS II dokumentu: vlevo je vyhledání a detail záznamu, pod ním formulář pro vložení nebo úpravu a v samostatném panelu se provádějí související akce nad verzemi a použitím assetu v projektech.

#figure(
  image("assets/form-annotated.png", width: 100%),
  caption: [Vygenerovaný návrh hlavní obrazovky systému správy assetů.],
)

#table(
  columns: (auto, 3fr),
  [*Část formuláře*], [*Účel*],
  [Vyhledat asset], [Vyhledání assetu podle identifikátoru nebo názvu a načtení jeho detailu.],
  [Informace o assetu], [Zobrazení názvu assetu, typu, autora, licence, formátu, velikosti, aktivity a popisu.],
  [Zobrazit verze], [Přehled všech verzí vybraného assetu včetně informace, která verze je schválená.],
  [Zobrazit projekty], [Seznam projektů, ve kterých je asset právě používán, včetně role použití.],
  [Přidat / upravit asset], [Formulář pro vložení nového assetu nebo úpravu jeho základních údajů.],
  [Přidat verzi], [Vložení nové verze assetu včetně cesty k souboru, changelogu a příznaku schválení.],
  [Přiřadit do projektu], [Zapsání použití assetu do konkrétního projektu s určením role a aktivního stavu.],
  [Statistiky], [Přehled nejčastěji používaných assetů v projektech.],
)

= Seznam funkcí

== CRUD F1 `GetAuthor(p_author_id)`

Funkce vrátí jméno autora. Vstupním parametrem je identifikátor autora, podle kterého vrátí výsledek.

```sql
select name from Author
where author_id = p_author_id
```

== CRUD F2 `GetAsset(p_asset_id)`

Funkce vrátí všechny informace o assetu (název, typ, hlavní autor, licence, formát, velikost, aktivní stav, popis). Jako parametr musí být poskytnut jednoznačný identifikátor assetu.

Funkce také zjistí, která schválená verze je pro daný asset aktuálně k dispozici.

```sql
select a.asset_id, a.name, at.name as asset_type, au.name as author_name,
       l.name as license_name, a.file_format, a.size_mb, a.created_at,
       a.is_active, a.description
from Asset a
join AssetType at on at.asset_type_id = a.asset_type_id
join Author au on au.author_id = a.main_author_id
join License l on l.license_id = a.license_id
where a.asset_id = p_asset_id

select max(version_number) from AssetVersion
where asset_id = p_asset_id
  and is_approved = TRUE
```

== F3 `GetAssetVersions(p_asset_id)`

Funkce vrátí všechny verze spojené s assetem s identifikátorem `p_asset_id`.

```sql
select * from AssetVersion
where asset_id = p_asset_id
order by version_number desc
```

== F4 `GetAssetProjects(p_asset_id)`

Funkce vrátí všechny projekty, ve kterých je zadaný asset použit.

```sql
select * from AssetProjectUsage apu
join Project p on p.project_id = apu.project_id
where apu.asset_id = p_asset_id
```

== F5 `AddAsset(p_asset_id, p_name, p_asset_type_id, p_main_author_id, p_license_id, p_file_format, p_size_mb, p_created_at, p_is_active, p_description)`

Transakce vloží nový asset do tabulky `Asset`. Před vložením ověřuje, že zadaný typ assetu, hlavní autor a licence v systému existují. Po úspěšném vložení je asset připraven k dalšímu verzování a přiřazení do projektů.

```sql
insert into Asset(asset_id, name, asset_type_id, main_author_id, license_id,
                  file_format, size_mb, created_at, is_active, description)
values(p_asset_id, p_name, p_asset_type_id, p_main_author_id, p_license_id,
       p_file_format, p_size_mb, p_created_at, p_is_active, p_description)
```

== T1 F6 `AddAssetVersion(p_asset_version_id, p_asset_id, p_version_number, p_file_path, p_created_at, p_changelog, p_is_approved)`

Transakce vloží záznam do tabulky `AssetVersion`. Pokud je nová verze označena jako schválená, všechny ostatní verze stejného assetu se automaticky nastaví jako neschválené, aby byla v systému vždy právě jedna schválená verze.

```sql
create or replace procedure AddAssetVersion(
  p_asset_version_id integer,
  p_asset_id integer,
  p_version_number integer,
  p_file_path varchar2,
  p_created_at date,
  p_changelog varchar2,
  p_is_approved number
) is
begin
  if p_is_approved = 1 then
    update AssetVersion
    set is_approved = 0
    where asset_id = p_asset_id;
  end if;

  insert into AssetVersion(
    asset_version_id, asset_id, version_number, file_path,
    created_at, changelog, is_approved
  )
  values (
    p_asset_version_id, p_asset_id, p_version_number, p_file_path,
    p_created_at, p_changelog, p_is_approved
  );
end;
```

== T2 F7 `AddAssetProjectUsage(p_asset_id, p_project_id, p_usage_role, p_added_at, p_is_active)`

Transakce vloží záznam do tabulky `AssetProjectUsage`. Před vložením kontroluje, zda licence přiřazeného assetu dovoluje použití v daném projektu. Pokud je projekt ve stavu `released`, může být použit pouze asset s komerčně použitelnou licencí.

```sql
create or replace procedure AddAssetProjectUsage(
  p_asset_id integer,
  p_project_id integer,
  p_usage_role varchar2,
  p_added_at date,
  p_is_active number
) is
  v_is_commercial number;
  v_status Project.status%type;
  v_invalid_license exception;
begin
  select l.is_commercial, p.status
  into v_is_commercial, v_status
  from Asset a
  join License l on l.license_id = a.license_id
  join Project p on p.project_id = p_project_id
  where a.asset_id = p_asset_id;

  if v_status = 'released' and v_is_commercial = 0 then
    raise v_invalid_license;
  end if;

  insert into AssetProjectUsage(asset_id, project_id, usage_role, added_at, is_active)
  values(p_asset_id, p_project_id, p_usage_role, p_added_at, p_is_active);
exception
  when v_invalid_license then
    dbms_output.put_line('Licence assetu neumožňuje použití ve vydaném projektu.');
end;
```

== CRUD F8 `EditAsset(p_asset_id, p_name, p_license_id, p_file_format, p_size_mb, p_is_active, p_description)`

Funkce aktualizuje záznam assetu na základě poskytnutého parametru `p_asset_id`.

```sql
update Asset
set name = p_name,
    license_id = p_license_id,
    file_format = p_file_format,
    size_mb = p_size_mb,
    is_active = p_is_active,
    description = p_description
where asset_id = p_asset_id
```

== CRUD F9 `FindAssets(p_asset_type_id, p_is_commercial)`

Funkce vrátí seznam aktivních assetů, které odpovídají zadanému typu a zvolenému licenčnímu omezení.

```sql
select a.* from Asset a
join License l on l.license_id = a.license_id
where a.asset_type_id = p_asset_type_id
  and a.is_active = TRUE
  and l.is_commercial = p_is_commercial
```

== F10 `GetStats()`

Funkce vrátí prvních deset assetů s nejvyšším počtem použití v projektech.

```sql
select a.asset_id, a.name, count(*) as usage_count
from AssetProjectUsage apu
join Asset a on a.asset_id = apu.asset_id
where apu.is_active = TRUE
group by a.asset_id, a.name
order by usage_count desc
fetch first 10 rows only
```

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
