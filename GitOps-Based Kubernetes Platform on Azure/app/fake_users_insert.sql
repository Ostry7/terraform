INSERT INTO users (name, email, role)
SELECT
  initcap(first_names.name || ' ' || last_names.name) AS name,
  lower(first_names.name || '.' || last_names.name || '@company.local') AS email,
  CASE
    WHEN i % 12 = 0 THEN 'admin'
    WHEN i % 5 = 0 THEN 'manager'
    ELSE 'user'
  END AS role
FROM generate_series(1, 500) i
JOIN (
  SELECT unnest(ARRAY[
    'Jan','Adam','Piotr','Kamil','Marek','Tomasz','Paweł','Łukasz','Jakub','Dawid',
    'Michał','Rafał','Szymon','Karol','Wojciech','Grzegorz','Patryk','Mateusz','Dominik','Bartosz'
  ]) AS name
) first_names ON true
JOIN (
  SELECT unnest(ARRAY[
    'Kowalski','Nowak','Wiśniewski','Wójcik','Kowalczyk','Kamiński','Lewandowski',
    'Zieliński','Szymański','Woźniak','Dąbrowski','Kozłowski','Jankowski','Mazur',
    'Kwiatkowski','Krawczyk','Piotrowski','Grabowski','Zając','Pawłowski'
  ]) AS name
) last_names ON true;