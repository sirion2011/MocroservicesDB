/*
Created: 29.04.2026
Modified: 29.04.2026
Model: Microsoft SQL Server 2019
Database: MS SQL Server 2019
*/
use master
go

if exists (select 1 from sys.databases where name = 'MicroService')
begin 
   alter database MicroService set single_user with rollback immediate; 
   drop database MicroService;

end

create database MicroService;
go

use MicroService;
go


-- Create tables section -------------------------------------------------

-- Table Service

CREATE TABLE [Service]
(
 [ServiceID] Int NOT NULL,
 [ServiceName] Nvarchar(50) NOT NULL,
 CONSTRAINT [PK_Service] PRIMARY KEY ([ServiceID])
)
AS NODE
go

-- Table API

CREATE TABLE [API]
(
 [APIID] Int NOT NULL,
 [APIName] Nvarchar(50) NOT NULL,
 [APIParameters] Nvarchar(100) NOT NULL,
 CONSTRAINT [PK_API] PRIMARY KEY ([APIID])
)
AS NODE
go

-- Table Expose

CREATE TABLE [Expose]
(
 [Tariff] Money DEFAULT 0 NOT NULL
)
AS EDGE
go

-- Add connection constraints for table Expose

ALTER TABLE [Expose] ADD CONSTRAINT [EC_Service_API] CONNECTION (
  [Service] TO [API])
go

-- Table Database

CREATE TABLE [Database]
(
 [DatabaseID] Int NOT NULL,
 [DBType] Nvarchar(30) NOT NULL,
 CONSTRAINT [PK_Database] PRIMARY KEY ([DatabaseID])
)
AS NODE
go

-- Table Calls

CREATE TABLE [Calls]
(
 [Status] Nvarchar(20) NOT NULL
)
AS EDGE
go

-- Add connection constraints for table Calls

ALTER TABLE [Calls] ADD CONSTRAINT [CC_Service_Service] CONNECTION (
  [Service] TO [Service])
go

-- Table UsesDatabase

CREATE TABLE [UsesDatabase]
(
 [AccessType] Nvarchar(20) NOT NULL
)
AS EDGE
go

-- Add connection constraints for table UsesDatabase

ALTER TABLE [UsesDatabase] ADD CONSTRAINT [UDC_Service_Database] CONNECTION (
  [Service] TO [Database])
go


INSERT INTO [Service] ([ServiceID], [ServiceName]) VALUES
(1, 'GatewayService'),
(2, 'UserService'),
(3, 'OrderService'),
(4, 'PaymentService');


INSERT INTO [API] ([APIID], [APIName], [APIParameters]) VALUES
-- GatewayService (1) - 3 API
(1, '/gateway/route', 'userId,orderId'),
(2, '/gateway/auth', 'token'),
(3, '/gateway/health', '-'),
-- UserService (2) - 4 API
(4, '/user/profile', 'userId'),
(5, '/user/register', 'name,email'),
(6, '/user/login', 'email,password'),
(7, '/user/delete', 'userId'),
-- OrderService (3) - 4 API
(8, '/order/create', 'userId,items'),
(9, '/order/status', 'orderId'),
(10, '/order/cancel', 'orderId'),
(11, '/order/history', 'userId'),
-- PaymentService (4) - 3 API
(12, '/payment/charge', 'orderId,amount'),
(13, '/payment/refund', 'orderId'),
(14, '/payment/method', 'userId');


INSERT INTO [Database] ([DatabaseID], [DBType]) VALUES
-- UserService
(1, 'PostgreSQL'),   -- основная
(2, 'Redis'),        -- кеш
-- OrderService
(3, 'PostgreSQL'),   -- основная
(4, 'Redis'),        -- кеш
-- PaymentService
(5, 'PostgreSQL'),   -- основная
(6, 'Redis'),        -- кеш
-- GatewayService
(7, 'PostgreSQL'),   -- основная
(8, 'Redis');        -- кеш


-- =============================================
-- 1. ЗАПОЛНЯЕМ Expose (Service -> API)
-- =============================================

DECLARE @node_id_from NVARCHAR(1000);
DECLARE @node_id_to NVARCHAR(1000);

-- GatewayService (1) -> API 1
SET @node_id_from = (SELECT $node_id FROM [Service] WHERE ServiceID = 1);
SET @node_id_to = (SELECT $node_id FROM [API] WHERE APIID = 1);
INSERT INTO [Expose] ($from_id, $to_id, Tariff) VALUES (@node_id_from, @node_id_to, 0);

-- GatewayService (1) -> API 2
SET @node_id_from = (SELECT $node_id FROM [Service] WHERE ServiceID = 1);
SET @node_id_to = (SELECT $node_id FROM [API] WHERE APIID = 2);
INSERT INTO [Expose] ($from_id, $to_id, Tariff) VALUES (@node_id_from, @node_id_to, 0);

-- GatewayService (1) -> API 3
SET @node_id_from = (SELECT $node_id FROM [Service] WHERE ServiceID = 1);
SET @node_id_to = (SELECT $node_id FROM [API] WHERE APIID = 3);
INSERT INTO [Expose] ($from_id, $to_id, Tariff) VALUES (@node_id_from, @node_id_to, 0);

-- UserService (2) -> API 4
SET @node_id_from = (SELECT $node_id FROM [Service] WHERE ServiceID = 2);
SET @node_id_to = (SELECT $node_id FROM [API] WHERE APIID = 4);
INSERT INTO [Expose] ($from_id, $to_id, Tariff) VALUES (@node_id_from, @node_id_to, 100);

-- UserService (2) -> API 5
SET @node_id_from = (SELECT $node_id FROM [Service] WHERE ServiceID = 2);
SET @node_id_to = (SELECT $node_id FROM [API] WHERE APIID = 5);
INSERT INTO [Expose] ($from_id, $to_id, Tariff) VALUES (@node_id_from, @node_id_to, 50);

-- UserService (2) -> API 6
SET @node_id_from = (SELECT $node_id FROM [Service] WHERE ServiceID = 2);
SET @node_id_to = (SELECT $node_id FROM [API] WHERE APIID = 6);
INSERT INTO [Expose] ($from_id, $to_id, Tariff) VALUES (@node_id_from, @node_id_to, 50);

-- UserService (2) -> API 7
SET @node_id_from = (SELECT $node_id FROM [Service] WHERE ServiceID = 2);
SET @node_id_to = (SELECT $node_id FROM [API] WHERE APIID = 7);
INSERT INTO [Expose] ($from_id, $to_id, Tariff) VALUES (@node_id_from, @node_id_to, 100);

-- OrderService (3) -> API 8
SET @node_id_from = (SELECT $node_id FROM [Service] WHERE ServiceID = 3);
SET @node_id_to = (SELECT $node_id FROM [API] WHERE APIID = 8);
INSERT INTO [Expose] ($from_id, $to_id, Tariff) VALUES (@node_id_from, @node_id_to, 200);

-- OrderService (3) -> API 9
SET @node_id_from = (SELECT $node_id FROM [Service] WHERE ServiceID = 3);
SET @node_id_to = (SELECT $node_id FROM [API] WHERE APIID = 9);
INSERT INTO [Expose] ($from_id, $to_id, Tariff) VALUES (@node_id_from, @node_id_to, 50);

-- OrderService (3) -> API 10
SET @node_id_from = (SELECT $node_id FROM [Service] WHERE ServiceID = 3);
SET @node_id_to = (SELECT $node_id FROM [API] WHERE APIID = 10);
INSERT INTO [Expose] ($from_id, $to_id, Tariff) VALUES (@node_id_from, @node_id_to, 100);

-- OrderService (3) -> API 11
SET @node_id_from = (SELECT $node_id FROM [Service] WHERE ServiceID = 3);
SET @node_id_to = (SELECT $node_id FROM [API] WHERE APIID = 11);
INSERT INTO [Expose] ($from_id, $to_id, Tariff) VALUES (@node_id_from, @node_id_to, 100);

-- PaymentService (4) -> API 12
SET @node_id_from = (SELECT $node_id FROM [Service] WHERE ServiceID = 4);
SET @node_id_to = (SELECT $node_id FROM [API] WHERE APIID = 12);
INSERT INTO [Expose] ($from_id, $to_id, Tariff) VALUES (@node_id_from, @node_id_to, 300);

-- PaymentService (4) -> API 13
SET @node_id_from = (SELECT $node_id FROM [Service] WHERE ServiceID = 4);
SET @node_id_to = (SELECT $node_id FROM [API] WHERE APIID = 13);
INSERT INTO [Expose] ($from_id, $to_id, Tariff) VALUES (@node_id_from, @node_id_to, 150);

-- PaymentService (4) -> API 14
SET @node_id_from = (SELECT $node_id FROM [Service] WHERE ServiceID = 4);
SET @node_id_to = (SELECT $node_id FROM [API] WHERE APIID = 14);
INSERT INTO [Expose] ($from_id, $to_id, Tariff) VALUES (@node_id_from, @node_id_to, 50);

-- =============================================
-- 2. ЗАПОЛНЯЕМ Calls (Service -> Service)
-- =============================================

DECLARE @from_id NVARCHAR(1000);
DECLARE @to_id NVARCHAR(1000);

-- Gateway (1) -> User (2)
SET @from_id = (SELECT $node_id FROM [Service] WHERE ServiceID = 1);
SET @to_id = (SELECT $node_id FROM [Service] WHERE ServiceID = 2);
INSERT INTO [Calls] ($from_id, $to_id, Status) VALUES (@from_id, @to_id, 'success');

-- Gateway (1) -> Order (3)
SET @from_id = (SELECT $node_id FROM [Service] WHERE ServiceID = 1);
SET @to_id = (SELECT $node_id FROM [Service] WHERE ServiceID = 3);
INSERT INTO [Calls] ($from_id, $to_id, Status) VALUES (@from_id, @to_id, 'success');

-- User (2) -> Order (3)
SET @from_id = (SELECT $node_id FROM [Service] WHERE ServiceID = 2);
SET @to_id = (SELECT $node_id FROM [Service] WHERE ServiceID = 3);
INSERT INTO [Calls] ($from_id, $to_id, Status) VALUES (@from_id, @to_id, 'success');

-- Order (3) -> Payment (4)
SET @from_id = (SELECT $node_id FROM [Service] WHERE ServiceID = 3);
SET @to_id = (SELECT $node_id FROM [Service] WHERE ServiceID = 4);
INSERT INTO [Calls] ($from_id, $to_id, Status) VALUES (@from_id, @to_id, 'success');

-- Order (3) -> User (2) [timeout]
SET @from_id = (SELECT $node_id FROM [Service] WHERE ServiceID = 3);
SET @to_id = (SELECT $node_id FROM [Service] WHERE ServiceID = 2);
INSERT INTO [Calls] ($from_id, $to_id, Status) VALUES (@from_id, @to_id, 'timeout');

-- Payment (4) -> Order (3) [error]
SET @from_id = (SELECT $node_id FROM [Service] WHERE ServiceID = 4);
SET @to_id = (SELECT $node_id FROM [Service] WHERE ServiceID = 3);
INSERT INTO [Calls] ($from_id, $to_id, Status) VALUES (@from_id, @to_id, 'error');


-- =============================================
-- 3. ЗАПОЛНЯЕМ UsesDatabase (Service -> Database)
-- =============================================

DECLARE @serv_id NVARCHAR(1000);
DECLARE @db_id NVARCHAR(1000);

-- Gateway (1) -> PostgreSQL (7)
SET @serv_id = (SELECT $node_id FROM [Service] WHERE ServiceID = 1);
SET @db_id = (SELECT $node_id FROM [Database] WHERE DatabaseID = 7);
INSERT INTO [UsesDatabase] ($from_id, $to_id, AccessType) VALUES (@serv_id, @db_id, 'both');

-- Gateway (1) -> Redis (8)
SET @serv_id = (SELECT $node_id FROM [Service] WHERE ServiceID = 1);
SET @db_id = (SELECT $node_id FROM [Database] WHERE DatabaseID = 8);
INSERT INTO [UsesDatabase] ($from_id, $to_id, AccessType) VALUES (@serv_id, @db_id, 'read');

-- User (2) -> PostgreSQL (1)
SET @serv_id = (SELECT $node_id FROM [Service] WHERE ServiceID = 2);
SET @db_id = (SELECT $node_id FROM [Database] WHERE DatabaseID = 1);
INSERT INTO [UsesDatabase] ($from_id, $to_id, AccessType) VALUES (@serv_id, @db_id, 'both');

-- User (2) -> Redis (2)
SET @serv_id = (SELECT $node_id FROM [Service] WHERE ServiceID = 2);
SET @db_id = (SELECT $node_id FROM [Database] WHERE DatabaseID = 2);
INSERT INTO [UsesDatabase] ($from_id, $to_id, AccessType) VALUES (@serv_id, @db_id, 'read');

-- Order (3) -> PostgreSQL (3)
SET @serv_id = (SELECT $node_id FROM [Service] WHERE ServiceID = 3);
SET @db_id = (SELECT $node_id FROM [Database] WHERE DatabaseID = 3);
INSERT INTO [UsesDatabase] ($from_id, $to_id, AccessType) VALUES (@serv_id, @db_id, 'both');

-- Order (3) -> Redis (4)
SET @serv_id = (SELECT $node_id FROM [Service] WHERE ServiceID = 3);
SET @db_id = (SELECT $node_id FROM [Database] WHERE DatabaseID = 4);
INSERT INTO [UsesDatabase] ($from_id, $to_id, AccessType) VALUES (@serv_id, @db_id, 'read');

-- Payment (4) -> PostgreSQL (5)
SET @serv_id = (SELECT $node_id FROM [Service] WHERE ServiceID = 4);
SET @db_id = (SELECT $node_id FROM [Database] WHERE DatabaseID = 5);
INSERT INTO [UsesDatabase] ($from_id, $to_id, AccessType) VALUES (@serv_id, @db_id, 'both');

-- Payment (4) -> Redis (6)
SET @serv_id = (SELECT $node_id FROM [Service] WHERE ServiceID = 4);
SET @db_id = (SELECT $node_id FROM [Database] WHERE DatabaseID = 6);
INSERT INTO [UsesDatabase] ($from_id, $to_id, AccessType) VALUES (@serv_id, @db_id, 'read');


-- Запрос 1: Найти все API, которые предоставляет сервис, и кто этот сервис 
-- вызывает (цепочка: Сервис → API ← Сервис → Calls → Сервис)
SELECT 
    s1.ServiceName AS service_name,
    a.APIName AS provided_api,
    s2.ServiceName AS called_service,
    c.Status AS call_status
FROM 
    [Service] s1,
    [Expose] e,
    [API] a,
    [Calls] c,
    [Service] s2
WHERE MATCH( s1-(e)->a AND s1-(c)->s2 )
ORDER BY s1.ServiceName;


-- Запрос 2: Найти сервисы, которые используют БД, и при этом вызывают 
-- другой сервис (цепочка: Сервис → UsesDatabase → БД и Сервис → Calls → Сервис)
SELECT 
    s.ServiceName AS service,
    d.DBType AS database_type,
    u.AccessType AS access_type,
    s2.ServiceName AS calls_service,
    c.Status AS call_status
FROM 
    [Service] s,
    [UsesDatabase] u,
    [Database] d,
    [Calls] c,
    [Service] s2
WHERE MATCH( s-(u)->d AND s-(c)->s2 )
ORDER BY s.ServiceName;


-- Запрос 3: Цепочка из трёх сервисов (Сервис A → Calls → Сервис B → Calls → Сервис C) с их API
SELECT 
    s1.ServiceName AS first_service,
    a.APIName AS api_of_first,
    s2.ServiceName AS second_service,
    c1.Status AS call_1_2_status,
    s3.ServiceName AS third_service,
    c2.Status AS call_2_3_status
FROM 
    [Service] s1,
    [Expose] e,
    [API] a,
    [Calls] c1,
    [Service] s2,
    [Calls] c2,
    [Service] s3
WHERE MATCH( s1-(e)->a AND s1-(c1)->s2-(c2)->s3 )
ORDER BY s1.ServiceName;


-- Запрос 4: Найти сервисы, которые используют PostgreSQL и вызывают другой сервис с ошибкой
SELECT 
    s1.ServiceName AS service_with_postgres,
    d.DBType,
    s2.ServiceName AS called_service,
    c.Status
FROM 
    [Service] s1,
    [UsesDatabase] u,
    [Database] d,
    [Calls] c,
    [Service] s2
WHERE MATCH( s1-(u)->d AND s1-(c)->s2 )
AND d.DBType = 'PostgreSQL'
AND c.Status IN ('error', 'timeout');


-- Запрос 5: Полный путь: Сервис → Calls → Сервис → UsesDatabase → БД
SELECT 
    caller.ServiceName AS caller_service,
    called.ServiceName AS called_service,
    c.Status AS call_status,
    d.DBType AS called_service_database,
    u.AccessType AS access_type
FROM 
    [Service] caller,
    [Calls] c,
    [Service] called,
    [UsesDatabase] u,
    [Database] d
WHERE MATCH( caller-(c)->called-(u)->d )
ORDER BY caller.ServiceName;


-- SHORTEST_PATH с шаблоном + (один или более шагов)
-- Найти кратчайший путь от GatewayService до всех достижимых сервисов
SELECT 
    STRING_AGG(s.ServiceName, ' -> ') WITHIN GROUP (GRAPH PATH) AS full_path,
    COUNT(s.ServiceName) WITHIN GROUP (GRAPH PATH) AS steps_count
FROM 
    [Service] AS start_node,
    [Service] FOR PATH AS s,
    [Calls] FOR PATH AS c
WHERE 
    MATCH( SHORTEST_PATH( start_node(-(c)->s)+ ) )
    AND start_node.ServiceID = 1;


-- SHORTEST_PATH с шаблоном {1,3}
-- Найти кратчайший путь от OrderService до всех сервисов за 1-3 шага
SELECT 
    STRING_AGG(s.ServiceName, ' -> ') WITHIN GROUP (GRAPH PATH) AS full_path,
    COUNT(s.ServiceName) WITHIN GROUP (GRAPH PATH) AS steps_count
FROM 
    [Service] AS start_node,
    [Service] FOR PATH AS s,
    [Calls] FOR PATH AS c
WHERE 
    MATCH( SHORTEST_PATH( start_node(-(c)->s){1,3} ) )
    AND start_node.ServiceID = 3;






--Power BI


-- Ребра Expose: какие API предоставляет каждый сервис
SELECT 
    s.ServiceName AS Source,
    a.APIName AS Target,
    CONCAT('service', s.ServiceID) AS [Source image name],
    CONCAT('api', a.APIID) AS [Target image name],
    e.Tariff AS Tariff,
    CONCAT('Tariff: ', CAST(e.Tariff AS NVARCHAR(20))) AS [Label]
FROM [Service] s, [Expose] e, [API] a
WHERE MATCH(s-(e)->a)
ORDER BY s.ServiceName


-- Ребра Calls: какие сервисы вызывают другие сервисы
SELECT 
    s1.ServiceName AS Source,
    s2.ServiceName AS Target,
    CONCAT('service', s1.ServiceID) AS [Source image name],
    CONCAT('service', s2.ServiceID) AS [Target image name],
    c.Status AS Status,
    c.Status AS [Label]
FROM [Service] s1, [Calls] c, [Service] s2
WHERE MATCH(s1-(c)->s2)
ORDER BY s1.ServiceName


-- Ребра UsesDatabase: какие базы данных использует каждый сервис
SELECT 
    s.ServiceName AS Source,
    CONCAT(d.DBType, ' (', CAST(d.DatabaseID AS NVARCHAR(10)), ')') AS Target,
    CONCAT('service', s.ServiceID) AS [Source image name],
    CONCAT('db', d.DatabaseID) AS [Target image name],
    u.AccessType AS Access,
    u.AccessType AS [Label]
FROM [Service] s, [UsesDatabase] u, [Database] d
WHERE MATCH(s-(u)->d)
ORDER BY s.ServiceName


SELECT @@SERVERNAME