-- Step 0: Enable PostGIS
CREATE EXTENSION postgis;

-- Step 1: Create tables

DROP TABLE if exists public.dim_users;

CREATE TABLE public.dim_users (
	user_id int4 NOT NULL,
	name_user varchar NOT NULL,
	rut_user int4 NOT NULL,
	CONSTRAINT dim_users_pk PRIMARY KEY (user_id)
);

DROP TABLE if exists public.dim_date;

CREATE TABLE public.dim_date (
	date_id int4 NOT NULL,
	full_date date NOT NULL,
	"day" int4 NOT NULL,
	"month" int4 NOT NULL,
	"year" int4 NOT NULL,
	CONSTRAINT dim_date_pk PRIMARY KEY (date_id)
);
CREATE UNIQUE INDEX dim_date_full_date_idx ON public.dim_date USING btree (full_date);

DROP TABLE if exists public.dim_time;

CREATE TABLE public.dim_time (
	time_id char(6) NOT NULL,
	"hour" int4 NOT NULL,
	"minute" int4 NOT NULL,
	"second" int4 NOT NULL,
	CONSTRAINT dim_time_pk PRIMARY KEY (time_id)
);

DROP TABLE if exists public.fact_trips;

CREATE TABLE public.fact_trips (
	trip_id int8 NOT NULL,
	status_id int4 NOT NULL,
	user_id int4 NOT NULL,
	membership_id int4 NOT NULL,
	vehicle_id int4 NOT NULL,
	booking_date_id int4 NOT NULL,
	booking_time_id char(6) NOT NULL,
	start_date_id int4 NULL,
	start_time_id char(6) NULL,
	end_date_id int4 NULL,
	end_time_id char(6) NULL,
	travel_dist int4 NULL,
	price_amount int4 NULL,
	price_tax numeric NULL,
	price_total int4 NULL,
	start_coordinates geometry(Point, 4326),
	end_coordinates geometry(Point, 4326),
	CONSTRAINT fact_trips_pk PRIMARY KEY (trip_id),
	CONSTRAINT fact_trips_booking_date_fk FOREIGN KEY (booking_date_id) REFERENCES public.dim_date(date_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT fact_trips_booking_time_fk FOREIGN KEY (booking_time_id) REFERENCES public.dim_time(time_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT fact_trips_end_date_fk FOREIGN KEY (end_date_id) REFERENCES public.dim_date(date_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT fact_trips_end_time_fk FOREIGN KEY (end_time_id) REFERENCES public.dim_time(time_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT fact_trips_start_date_fk FOREIGN KEY (start_date_id) REFERENCES public.dim_date(date_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT fact_trips_start_time_fk FOREIGN KEY (start_time_id) REFERENCES public.dim_time(time_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT fact_trips_user_id_fk FOREIGN KEY (user_id) REFERENCES public.dim_users(user_id) ON DELETE RESTRICT ON UPDATE CASCADE
);


-- Step 2: Populate dim_date and dim_time tables
INSERT INTO dim_date
SELECT 
	TO_CHAR(date_seq, 'yyyymmdd')::INT AS date_id,
	date_seq AS full_date,
	EXTRACT(DAY FROM date_seq) AS day,
	EXTRACT(MONTH FROM date_seq) AS month,
	EXTRACT(YEAR FROM date_seq) AS year
FROM
	(SELECT series.day::date AS date_seq
	 FROM
	 	generate_series(timestamp '2022-01-01',
		 				timestamp '2023-12-31',
						interval '1 day'
		) AS series(day)
	) AS dates
ORDER BY 1;

INSERT INTO dim_time
SELECT
	TO_CHAR(time_seq, 'hh24miss') AS time_id,
	EXTRACT(HOUR FROM time_seq) AS hour,
	EXTRACT(MINUTE FROM time_seq) AS minute,
	EXTRACT(SECOND FROM time_seq) AS second
FROM
	(SELECT series.second::time AS time_seq
	 FROM
	 	generate_series(timestamp '2022-01-01 00:00:00',
						timestamp '2022-01-01 23:59:59',
						interval '1 second'
		) AS series(second)
	) AS times


