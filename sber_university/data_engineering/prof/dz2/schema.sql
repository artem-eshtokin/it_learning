CREATE TABLE brand (
    brand_id        INTEGER CONSTRAINT pk_brand_brand_id PRIMARY KEY,
    brand_car_name  VARCHAR(100) NOT NULL CONSTRAINT uq_brand_brand_car_name UNIQUE
                   );

CREATE TABLE model (
    model_id            INTEGER CONSTRAINT pk_model_model_id PRIMARY KEY,
    brand               INTEGER,
    name                VARCHAR(100) NOT NULL,
	configuration_code  VARCHAR(30),
	price               DECIMAL(12,2),
	quantity            INTEGER
                   );

CREATE TABLE orders_model (
    model     INTEGER,
	orders    INTEGER,
	price     DECIMAL(12,2),
	quantity  INTEGER
                         );

CREATE TABLE orders (
    order_id   INTEGER CONSTRAINT pk_order_order_id PRIMARY KEY,
    client     INTEGER,
	comment_o  VARCHAR(255)
                   );

CREATE TABLE client (
    client_id   INTEGER CONSTRAINT pk_client_client_id PRIMARY KEY,
    first_name  VARCHAR(30) NOT NULL,
	patronymic  VARCHAR(30),
	last_name   VARCHAR(30),
	phone       VARCHAR(20),
	email       VARCHAR(50)
                    );

CREATE TABLE orders_step (
    orders     INTEGER,
	step       INTEGER,
	date_begin TIMESTAMP NOT NULL,
	date_end   TIMESTAMP
                        );

CREATE TABLE step (
    step_id  INTEGER CONSTRAINT pk_step_step_id PRIMARY KEY,
    name     VARCHAR(20) NOT NULL CONSTRAINT uq_step_name UNIQUE
                  );

ALTER TABLE model
  ADD CONSTRAINT fk_model_brand FOREIGN KEY (brand)
                                REFERENCES brand(brand_id);

ALTER TABLE orders_model
  ADD CONSTRAINT fk_orders_model_model FOREIGN KEY (model)
                                       REFERENCES model(model_id);

ALTER TABLE orders_model
  ADD CONSTRAINT fk_orders_model_order FOREIGN KEY (orders)
                                       REFERENCES orders(order_id);

ALTER TABLE orders
  ADD CONSTRAINT fk_orders_client FOREIGN KEY (client)
                                  REFERENCES client(client_id);

ALTER TABLE orders_step
  ADD CONSTRAINT fk_orders_step_orders FOREIGN KEY (orders)
                                       REFERENCES orders(order_id);

ALTER TABLE orders_step
  ADD CONSTRAINT fk_orders_step_step FOREIGN KEY (step)
                                     REFERENCES step(step_id);

INSERT INTO brand
       (brand_id, brand_car_name)
VALUES (1, 'Audi'),
       (2, 'BMW'),
       (3, 'Mercedes'),
       (4, 'Volvo');

INSERT INTO model
       (model_id, brand, name, configuration_code, price, quantity)
VALUES (1, 1, 'A4',   'R092580',       2500000.00, 5),
       (2, 2, 'X5',   'FGV_145_22',    7800000.00, 2),
       (3, 2, 'M5',   'KMN_806_20',    6200000.00, 1),
       (4, 1, 'Q7',   'R088352',       7350500.00, 2),
       (5, 3, 'GLB',  'ECBAU',         4990999.00, 3),
       (6, 4, 'XC60', 'V_46899276890', 5130000.00, 4),
       (7, 2, 'X5',   'FGV_159_22',    8190000.00, 1);

INSERT INTO client
       (client_id, first_name, patronymic, last_name, phone, email)
VALUES (1, 'Иван',    'Иванович',	'Иванов',     '8 910 000-00-01', Null),
       (2, 'Петр',    'Петрович',	'Петров',     '8 915 666-55-44', 'petr@100500plus.ru'),
       (3, 'Сидр',    'Сидрович',	'Сидоров',    '8 916 916-91-91', Null),
       (4, 'Евгения', 'Евгеньевна', 'Автогенова', '8 910 800-80-80', 'instagram_madam@mail-mail.ru');

INSERT INTO orders
       (order_id, client, comment_o)
VALUES (1, 1, 'Звонок по рекламе. Пригласить посмотреть Volvo.'),
       (2, 4, Null),
       (3, 2, Null),
       (4, 4, 'Второй раз обращается, ищет машину отцу.');

INSERT INTO orders_model
       (model, orders, price, quantity)
VALUES (4, 2, 6615450.00, 1),
       (6, 1, 4976100.00, 1),
       (2, 3, 7800000.00, 1),
       (3, 3, 6000000.00, 1),
       (5, 4, 4242349.50, 1);

INSERT INTO step
       (step_id, name)
VALUES (1, 'Переговоры'),
       (2, 'Резерв'),
       (3, 'Оплата'),
       (4, 'Транспортировка'),
       (5, 'Подготовка'),
       (6, 'Выдача');

INSERT INTO orders_step
       (orders, step, date_begin, date_end)
VALUES (1, 1, TO_TIMESTAMP('2023-01-09 12:15:10', 'YYYY-MM-DD HH24-MI-SS'), TO_TIMESTAMP('2023-01-12 10:15:10', 'YYYY-MM-DD HH24-MI-SS')),
       (2, 1, TO_TIMESTAMP('2023-01-09 15:11:00', 'YYYY-MM-DD HH24-MI-SS'), TO_TIMESTAMP('2023-01-10 11:11:00', 'YYYY-MM-DD HH24-MI-SS')),
       (3, 2, TO_TIMESTAMP('2023-01-09 18:08:54', 'YYYY-MM-DD HH24-MI-SS'), TO_TIMESTAMP('2023-01-09 19:18:44', 'YYYY-MM-DD HH24-MI-SS')),
       (3, 3, TO_TIMESTAMP('2023-01-09 19:18:44', 'YYYY-MM-DD HH24-MI-SS'), TO_TIMESTAMP('2023-01-15 10:00:00', 'YYYY-MM-DD HH24-MI-SS')),
       (2, 2, TO_TIMESTAMP('2023-01-10 11:11:00', 'YYYY-MM-DD HH24-MI-SS'), TO_TIMESTAMP('2023-01-13 20:00:00', 'YYYY-MM-DD HH24-MI-SS')),
       (1, 3, TO_TIMESTAMP('2023-01-12 10:15:10', 'YYYY-MM-DD HH24-MI-SS'), Null),
       (2, 3, TO_TIMESTAMP('2023-01-13 20:00:00', 'YYYY-MM-DD HH24-MI-SS'), TO_TIMESTAMP('2023-01-15 10:00:00', 'YYYY-MM-DD HH24-MI-SS')),
       (2, 4, TO_TIMESTAMP('2023-01-15 10:00:00', 'YYYY-MM-DD HH24-MI-SS'), TO_TIMESTAMP('2023-01-17 12:00:00', 'YYYY-MM-DD HH24-MI-SS')),
       (3, 4, TO_TIMESTAMP('2023-01-15 10:00:00', 'YYYY-MM-DD HH24-MI-SS'), Null),
       (2, 5, TO_TIMESTAMP('2023-01-17 12:00:00', 'YYYY-MM-DD HH24-MI-SS'), TO_TIMESTAMP('2023-01-17 20:00:00', 'YYYY-MM-DD HH24-MI-SS')),
       (2, 6, TO_TIMESTAMP('2023-01-18 15:00:00', 'YYYY-MM-DD HH24-MI-SS'), TO_TIMESTAMP('2023-01-18 17:00:00', 'YYYY-MM-DD HH24-MI-SS')),
       (4, 2, TO_TIMESTAMP('2023-01-18 16:00:00', 'YYYY-MM-DD HH24-MI-SS'), Null);