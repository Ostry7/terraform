INSERT INTO products (name, price, category)
SELECT
  product_names.name || ' ' || i AS name,
  round((base_price + (random() * variance))::numeric, 2) AS price,
  category
FROM generate_series(1, 500) i
JOIN (
  SELECT * FROM (VALUES
    ('Dell Monitor 27"', 1200, 400, 'it'),
    ('Logitech MX Master 3S', 350, 80, 'it'),
    ('Mechanical Keyboard Keychron K8', 450, 150, 'it'),
    ('USB-C Docking Station', 600, 200, 'it'),
    ('SSD NVMe 1TB Samsung', 500, 150, 'it'),

    ('Office Chair Ergonomic', 900, 300, 'office'),
    ('Standing Desk Frame', 1200, 400, 'office'),
    ('LED Desk Lamp', 120, 40, 'office'),
    ('Notebook A4 Premium', 25, 10, 'office'),

    ('Hammer Steel Pro', 60, 20, 'tools'),
    ('Screwdriver Set 24pcs', 80, 30, 'tools'),
    ('Electric Drill 750W', 300, 120, 'tools'),

    ('Coffee Beans Arabica 1kg', 90, 25, 'food'),
    ('Protein Bar Box', 120, 40, 'food'),
    ('Mineral Water Pack', 30, 10, 'food')
  ) AS t(name, base_price, variance, category)
) product_names ON true;