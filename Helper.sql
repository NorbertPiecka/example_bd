-- Example of creating table #1
CREATE TABLE Country (
    id INTEGER NOT NULL IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(30) NOT NULL,
    marketId INTEGER NOT NULL FOREIGN KEY REFERENCES Market(id)
);

-- Exampel of creating table #2
CREATE TABLE Order_detail (
    id INTEGER NOT NULL IDENTITY(1,1) PRIMARY KEY,
    sales FLOAT(2) NOT NULL CHECK (sales > 0),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    discount FLOAT(3) NOT NULL CHECK (discount between 0 and 1),
    profit FLOAT(2) NOT NULL,
    shipCost FLOAT(3) NOT NULL,
    orderId INTEGER NOT NULL FOREIGN KEY REFERENCES [Order](id),
    productId INTEGER NOT NULL FOREIGN KEY REFERENCES Product(id)
);
GO

-- Example of function
CREATE OR ALTER FUNCTION getCountryId (@countryName VARCHAR(30)) RETURNS INTEGER
AS BEGIN
    DECLARE @country_id INTEGER;

    SELECT @country_id = (SELECT id FROM Country WHERE name = @countryName);

    RETURN @country_id;
END
GO

-- Example of procedure
CREATE OR ALTER PROCEDURE insertCountry (@countryName VARCHAR(30), @marketId INTEGER)
AS BEGIN
    DECLARE @country_id INTEGER;

    SELECT @country_id = dbo.getCountryId(@countryName);
    IF @country_id IS NULL
        INSERT INTO Country(name, marketId) VALUES (@countryName, @marketId);
END
GO

-- Exec of procedure
EXEC insertCountry @countryName = @country, @marketId = @market_id;

-- Example of join
SELECT O.id AS order_id,
               O.orderDate AS order_date,
               O.shipDate AS ship_date,
               P.name AS product_name,
               D.sales AS sales,
               D.quantity AS quantity,
               D.profit AS profit
        FROM [Order] O
            JOIN Order_detail D on O.id = D.orderId
            JOIN Product P on D.productId = P.id
            JOIN Subcategory S on P.subCatId = S.id
            JOIN Address A on O.addressId = A.id
            JOIN Country C on A.countryId = C.id
        WHERE S.name = @subcategory
        AND   C.name = @country

-- Example of view
CREATE OR ALTER VIEW [dbo].[getCustomersWithOrder]
WITH SCHEMABINDING
    AS
    SELECT C.id AS customer_id,
           C.name AS customer_name,
           S.name AS segment_name,
           COUNT_BIG(*) AS count
    FROM dbo.Customer C
    JOIN dbo.Segment S on C.segId = S.id
    JOIN dbo.[Order] O on C.id = O.customerId
    GROUP BY C.id, C.name, S.name
GO