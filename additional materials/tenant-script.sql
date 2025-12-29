-- Skripta za kreiranje 10 tenantov (tenant_1 do tenant_10)
DO $$ 
BEGIN 
    FOR i IN 1..10 LOOP
        -- Dinamično ime sheme
        EXECUTE 'CREATE SCHEMA IF NOT EXISTS tenant_' || i;

        -- 1. Tabele za ORDER service
        EXECUTE 'CREATE TABLE IF NOT EXISTS tenant_' || i || '.orders (
            id serial4 NOT NULL,
			user_id int4 NOT NULL,
			partner_id int4 NULL,
			order_status varchar(30) NOT NULL,
			payment_status varchar(30) NOT NULL,
			payment_id int4 NULL,
			created_at timestamptz DEFAULT now() NULL,
			updated_at timestamptz DEFAULT now() NULL,
			CONSTRAINT orders_pkey PRIMARY KEY (id)
        )';

		EXECUTE 'CREATE TABLE IF NOT EXISTS tenant_' || i || '.order_item (
			id serial4 NOT NULL,
			order_id int4 NULL,
			offer_id int4 NOT NULL,
			quantity int4 NOT NULL,
			CONSTRAINT order_item_pkey PRIMARY KEY (id)
		)';

		EXECUTE 'ALTER TABLE tenant_' || i || '.order_item ADD CONSTRAINT order_item_order_id_fkey FOREIGN KEY (order_id) REFERENCES tenant_' || i || '.orders(id) ON DELETE CASCADE';


        -- 2. Tabele za PAYMENT service
        EXECUTE 'CREATE TABLE IF NOT EXISTS tenant_' || i || '.payments (
            id serial4 NOT NULL,
			order_id int4 NOT NULL,
			user_id int4 NOT NULL,
			amount numeric(10, 2) NOT NULL,
			currency varchar(10) NOT NULL,
			payment_method varchar(50) NOT NULL,
			payment_status varchar(20) NOT NULL,
			provider varchar(50) NOT NULL,
			transaction_id varchar(255) NOT NULL,
			created_at timestamptz DEFAULT now() NULL,
			updated_at timestamptz DEFAULT now() NULL,
			CONSTRAINT payments_pkey PRIMARY KEY (id),
			CONSTRAINT payments_transaction_id_key UNIQUE (transaction_id)
        )';

		EXECUTE 'CREATE INDEX ix_payments_id ON tenant_' || i || '.payments USING btree (id)';

		EXECUTE 'CREATE TABLE tenant_' || i || '.partners (
			id serial4 NOT NULL,
			"name" varchar NOT NULL,
			address varchar NULL,
			city varchar NULL,
			active bool NULL,
			tenant_id varchar NULL,
			CONSTRAINT partners_pkey PRIMARY KEY (id)
		)';
		
		EXECUTE 'CREATE INDEX ix_partners_id ON tenant_' || i || '.partners USING btree (id)';

        -- 3. Tabele za OFFER service
        EXECUTE 'CREATE TABLE IF NOT EXISTS tenant_' || i || '.offers (
            id serial4 NOT NULL,
			partner_id int4 NOT NULL,
			title varchar NOT NULL,
			description varchar NULL,
			price_original float8 NOT NULL,
			price_discounted float8 NOT NULL,
			quantity_total int4 NOT NULL,
			quantity_available int4 NOT NULL,
			pickup_from timestamp NOT NULL,
			pickup_until timestamp NOT NULL,
			status varchar NULL,
			tenant_id varchar NULL,
			CONSTRAINT offers_pkey PRIMARY KEY (id)
        )';

		EXECUTE 'CREATE INDEX ix_offers_id ON tenant_' || i || '.offers USING btree (id)';
    END LOOP;
END $$;