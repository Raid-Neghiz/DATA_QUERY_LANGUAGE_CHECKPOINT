CREATE TABLE Products(
    ProductID INT PRIMARY KEY ,
    ProductName VARCHAR(20) NOT NULL , 
    ProductType VARCHAR(20) NOT NULL ,
    Price FLOAT NOT NULL 
    ) ;


CREATE TABLE Customers(
    CustomerID INT PRIMARY KEY ,
    CustomerName VARCHAR (20) NOT NULL ,
    Email VARCHAR (50) NOT NULL ,
    Phone VARCHAR (20) NOT NULL 
) ;



CREATE TABLE Orders(
    OrderID INT PRIMARY KEY , 
    CustomerID INT FOREIGN KEY REFERENCES Products (ProductID) NOT NULL ,
    OrderDate DATE NOT NULL 
) ;


CREATE TABLE OrderDetails(
    OrderDetailID INT PRIMARY KEY ,
    OrderID INT FOREIGN KEY REFERENCES Orders (OrderID) NOT NULL ,
    ProductID INT FOREIGN KEY REFERENCES Products (ProductID) NOT NULL ,
    Quantity INT NOT NULL 
) ;


CREATE TABLE ProductTypes(
    ProductTypeID INT PRIMARY KEY ,
    ProductTypeName VARCHAR(20) NOT NULL
) ; 


-- INSERTING RECORDS :


INSERT INTO Products VALUES (1,'Widget A','Widget',10.00) , (2,'Widget B','Widget',15.00) , (3,'Gadget X','Gadget',20.00) , (4,'Gadget Y','Gadget',25.00 ) , (5,'Doohickey Z','Doohickey',30.00) ;

INSERT INTO Customers VALUES (1,'John Smith','john@example.com','123-456-7890') , (2,'Jane Doe','jane.doe@example.com','987-654-3210') , (3,'Alice Brown','alice.brown@example.com','456-789-0123') ;

INSERT INTO Orders VALUES (101,1,'2024-05-01') , (102,2,'2024-05-02') , (103,3,'2024-05-01') ;

INSERT INTO OrderDetails VALUES (1,101,1,2) , (2,101,3,1) , (3,102,2,3) , (4,102,4,2) , (5,103,5,1) ;

INSERT INTO ProductTypes VALUES (1,'Widget') , (2,'Gadget') , (3,'Doohickey') ;


--Retrieve all products :
SELECT * FROM Products ;

--Retrieve all customers :
SELECT * FROM Customers ;

--Retrieve all orders : 
SELECT * FROM Orders ;

--Retrieve all order details :
SELECT * FROM OrderDetails ;

--Retrieve all product types :
SELECT * FROM ProductTypes ;


--Retrieve the names of the products that have been ordered by at least one customer, along with the total quantity of each product ordered :

SELECT Products.ProductID , Products.ProductName , NEW_TABLE.Number_of_orders , NEW_TABLE.total_quantity_ordered 
FROM Products
JOIN ( SELECT OD1.ProductID , COUNT(OD1.OrderID) AS Number_of_orders , SUM(OD1.Quantity) AS total_quantity_ordered
        FROM OrderDetails OD1
        JOIN Products P1
        ON OD1.ProductID = P1.ProductID
        GROUP BY OD1.ProductID
        HAVING COUNT(OD1.OrderID) >= 1 ) AS NEW_TABLE
ON NEW_TABLE.ProductID = Products.ProductID ;


--Retrieve the names of the customers who have placed an order on every day of the week, along with the total number of orders placed by each customer :



SELECT Customers.CustomerID, CustomerName , OrderDate ,Number_Of_Orders
FROM Customers , Orders ,(SELECT OrderID ,COUNT(OrderID) AS Number_Of_Orders
                          FROM OrderDetails
                          GROUP BY OrderID ) AS COUNTING_ORDERS
WHERE Customers.CustomerID = Orders.CustomerID AND Orders.OrderID = COUNTING_ORDERS.OrderID ;



--Retrieve the names of the customers who have placed the most orders, along with the total number of orders placed by each customer :


SELECT  NEW_TABLE_OF_ORDERS.CustomerID ,CS.CustomerName , NEW_TABLE_OF_ORDERS.NUMBER_OF_ORDERS_FOR_EACH_CUSTOMER
 FROM Customers CS 
JOIN (SELECT O.CustomerID , COUNT(O.OrderID) AS NUMBER_OF_ORDERS_FOR_EACH_CUSTOMER 
      FROM Customers C 
      JOIN Orders O 
      ON C.CustomerID = O.CustomerID 
      GROUP BY O.CustomerID 
       HAVING COUNT(O.OrderID) =  (SELECT MAX(COUNTING_SUBQUERY.COUNTING_ORDERS) AS MAXIMUM_NUMBER_OF_ORDERS
                                    FROM (SELECT COUNT(O1.OrderID) AS COUNTING_ORDERS
                                          FROM Orders O1
                                          GROUP BY O1.CustomerID) AS COUNTING_SUBQUERY
                                   )) AS NEW_TABLE_OF_ORDERS 
ON CS.CustomerID = NEW_TABLE_OF_ORDERS.CustomerID ;                                                                      


--Retrieve the names of the products that have been ordered the most, along with the total quantity of each product ordered : 



SELECT P.ProductName , Virtual_Table.Orders_Numbre
FROM Products P
JOIN (SELECT ProductID , COUNT(OrderID) AS Orders_Numbre
      FROM OrderDetails
      GROUP BY ProductID
      HAVING COUNT(OrderID) = (SELECT  MAX(Number_Of_Orders)
                               FROM (SELECT ProductID , COUNT(OrderID) AS Number_Of_Orders
                                     FROM OrderDetails
                                     GROUP BY ProductID) AS Number_Of_Orders_for_Each_Product
                              ) ) AS Virtual_Table 
ON P.ProductID = Virtual_Table.ProductID ;


--Retrieve the names of customers who have placed an order for at least one widget : 

SELECT CustomerName
FROM Customers
WHERE CustomerID IN (SELECT CustomerID
                     FROM Orders 
                    WHERE OrderID IN (SELECT OrderID
                                      FROM OrderDetails
                                      WHERE ProductID IN (SELECT ProductID
                                                          FROM Products
                                                          WHERE ProductType ='Widget')) 
                    ) ;



--Retrieve the names of the customers who have placed an order for at least one widget and at least one gadget, along with the total cost of the widgets and gadgets ordered by each customer                    

SELECT CC.CustomerName  , JOIN_TABLE.Quantity , JOIN_TABLE.THE_TOTAL_PRICE
FROM Customers CC 
JOIN (
            SELECT C1.CustomerID , TABLE_OF_QUANTITIES_AND_PRICES.Quantity , (TABLE_OF_QUANTITIES_AND_PRICES.Quantity * TABLE_OF_QUANTITIES_AND_PRICES.Price) AS THE_TOTAL_PRICE
            FROM Customers C1
            JOIN Orders O1
            ON C1.CustomerID = O1.CustomerID
            JOIN (SELECT OD1.OrderID ,OD1.Quantity ,  P1.Price
                FROM Products P1
                JOIN OrderDetails OD1
                ON P1.ProductID = OD1.ProductID 
                WHERE P1.ProductType = 'Widget'
                UNION
                 SELECT OD2.OrderID ,OD2.Quantity ,  P2.Price
                FROM Products P2
                JOIN OrderDetails OD2
                ON P2.ProductID = OD2.ProductID 
                WHERE P2.ProductType = 'Gadget') AS TABLE_OF_QUANTITIES_AND_PRICES
            ON O1.OrderID = TABLE_OF_QUANTITIES_AND_PRICES.OrderID 
     )  AS JOIN_TABLE
ON CC.CustomerID = JOIN_TABLE.CustomerID ;


--Retrieve the names of the customers who have placed an order for at least one gadget, along with the total cost of the gadgets ordered by each customer : 


 SELECT CC.CustomerName  , JOIN_TABLE.Quantity , JOIN_TABLE.THE_TOTAL_PRICE
FROM Customers CC 
JOIN (
            SELECT C1.CustomerID , TABLE_OF_QUANTITIES_AND_PRICES.Quantity , (TABLE_OF_QUANTITIES_AND_PRICES.Quantity * TABLE_OF_QUANTITIES_AND_PRICES.Price) AS THE_TOTAL_PRICE
            FROM Customers C1
            JOIN Orders O1
            ON C1.CustomerID = O1.CustomerID
            JOIN (SELECT OD1.OrderID ,OD1.Quantity ,  P1.Price
                FROM Products P1
                JOIN OrderDetails OD1
                ON P1.ProductID = OD1.ProductID 
                WHERE P1.ProductType = 'Gadget'
             ) AS TABLE_OF_QUANTITIES_AND_PRICES
            ON O1.OrderID = TABLE_OF_QUANTITIES_AND_PRICES.OrderID 
     )  AS JOIN_TABLE
ON CC.CustomerID = JOIN_TABLE.CustomerID   ;        


--Retrieve the names of the customers who have placed an order for at least one doohickey, along with the total cost of the doohickeys ordered by each customer :

 SELECT CC.CustomerName  , JOIN_TABLE.Quantity , JOIN_TABLE.THE_TOTAL_PRICE
FROM Customers CC 
JOIN (
            SELECT C1.CustomerID , TABLE_OF_QUANTITIES_AND_PRICES.Quantity , (TABLE_OF_QUANTITIES_AND_PRICES.Quantity * TABLE_OF_QUANTITIES_AND_PRICES.Price) AS THE_TOTAL_PRICE
            FROM Customers C1
            JOIN Orders O1
            ON C1.CustomerID = O1.CustomerID
            JOIN (SELECT OD1.OrderID ,OD1.Quantity ,  P1.Price
                FROM Products P1
                JOIN OrderDetails OD1
                ON P1.ProductID = OD1.ProductID 
                WHERE P1.ProductType = 'Doohickey'
             ) AS TABLE_OF_QUANTITIES_AND_PRICES
            ON O1.OrderID = TABLE_OF_QUANTITIES_AND_PRICES.OrderID 
     )  AS JOIN_TABLE
ON CC.CustomerID = JOIN_TABLE.CustomerID  ; 

--Retrieve the total number of widgets and gadgets ordered by each customer, along with the total cost of the orders : 

            SELECT C1.CustomerName , JOIN_TABLE_2.ProductType , JOIN_TABLE_2.Quantity , JOIN_TABLE_2.TOTAL_COST
            FROM Customers C1
            JOIN (   
                    SELECT O1.CustomerID , JOIN_TABLE1.ProductType ,JOIN_TABLE1.Quantity , JOIN_TABLE1.TOTAL_COST
                    FROM Orders O1
                    JOIN (

                        SELECT  OD1.OrderID ,OD1.ProductID ,P1.ProductType ,OD1.Quantity , (OD1.Quantity * P1.Price) AS TOTAL_COST
                        FROM OrderDetails OD1 
                        JOIN Products P1
                        ON OD1.ProductID = P1.ProductID
                        WHERE OD1.ProductID IN ( 
                                                    SELECT PP1.ProductID
                                                    FROM Products PP1
                                                    WHERE PP1.ProductType = 'Widget' 
                                                    UNION 
                                                    SELECT PP1.ProductID
                                                    FROM Products PP1
                                                    WHERE PP1.ProductType = 'Gadget' 
                                                ) 
                        ) AS JOIN_TABLE1 
                    ON O1.OrderID = JOIN_TABLE1.OrderID      

                 ) AS JOIN_TABLE_2
             ON C1.CustomerID = JOIN_TABLE_2.CustomerID ;   
             



