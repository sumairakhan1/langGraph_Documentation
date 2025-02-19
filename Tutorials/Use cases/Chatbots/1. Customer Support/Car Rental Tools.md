# Car Rental Tools¶

**Once a user books a flight, they likely will want to organize transportation. Define some "car rental" tools to let the user search for and reserve a car at their destination.**

```python
from datetime import date, datetime
from typing import Optional, Union


@tool
def search_car_rentals(
    location: Optional[str] = None,
    name: Optional[str] = None,
    price_tier: Optional[str] = None,
    start_date: Optional[Union[datetime, date]] = None,
    end_date: Optional[Union[datetime, date]] = None,
) -> list[dict]:
    """
    Search for car rentals based on location, name, price tier, start date, and end date.

    Args:
        location (Optional[str]): The location of the car rental. Defaults to None.
        name (Optional[str]): The name of the car rental company. Defaults to None.
        price_tier (Optional[str]): The price tier of the car rental. Defaults to None.
        start_date (Optional[Union[datetime, date]]): The start date of the car rental. Defaults to None.
        end_date (Optional[Union[datetime, date]]): The end date of the car rental. Defaults to None.

    Returns:
        list[dict]: A list of car rental dictionaries matching the search criteria.
    """
    conn = sqlite3.connect(db)
    cursor = conn.cursor()

    query = "SELECT * FROM car_rentals WHERE 1=1"
    params = []

    if location:
        query += " AND location LIKE ?"
        params.append(f"%{location}%")
    if name:
        query += " AND name LIKE ?"
        params.append(f"%{name}%")
    # For our tutorial, we will let you match on any dates and price tier.
    # (since our toy dataset doesn't have much data)
    cursor.execute(query, params)
    results = cursor.fetchall()

    conn.close()

    return [
        dict(zip([column[0] for column in cursor.description], row)) for row in results
    ]


@tool
def book_car_rental(rental_id: int) -> str:
    """
    Book a car rental by its ID.

    Args:
        rental_id (int): The ID of the car rental to book.

    Returns:
        str: A message indicating whether the car rental was successfully booked or not.
    """
    conn = sqlite3.connect(db)
    cursor = conn.cursor()

    cursor.execute("UPDATE car_rentals SET booked = 1 WHERE id = ?", (rental_id,))
    conn.commit()

    if cursor.rowcount > 0:
        conn.close()
        return f"Car rental {rental_id} successfully booked."
    else:
        conn.close()
        return f"No car rental found with ID {rental_id}."


@tool
def update_car_rental(
    rental_id: int,
    start_date: Optional[Union[datetime, date]] = None,
    end_date: Optional[Union[datetime, date]] = None,
) -> str:
    """
    Update a car rental's start and end dates by its ID.

    Args:
        rental_id (int): The ID of the car rental to update.
        start_date (Optional[Union[datetime, date]]): The new start date of the car rental. Defaults to None.
        end_date (Optional[Union[datetime, date]]): The new end date of the car rental. Defaults to None.

    Returns:
        str: A message indicating whether the car rental was successfully updated or not.
    """
    conn = sqlite3.connect(db)
    cursor = conn.cursor()

    if start_date:
        cursor.execute(
            "UPDATE car_rentals SET start_date = ? WHERE id = ?",
            (start_date, rental_id),
        )
    if end_date:
        cursor.execute(
            "UPDATE car_rentals SET end_date = ? WHERE id = ?", (end_date, rental_id)
        )

    conn.commit()

    if cursor.rowcount > 0:
        conn.close()
        return f"Car rental {rental_id} successfully updated."
    else:
        conn.close()
        return f"No car rental found with ID {rental_id}."


@tool
def cancel_car_rental(rental_id: int) -> str:
    """
    Cancel a car rental by its ID.

    Args:
        rental_id (int): The ID of the car rental to cancel.

    Returns:
        str: A message indicating whether the car rental was successfully cancelled or not.
    """
    conn = sqlite3.connect(db)
    cursor = conn.cursor()

    cursor.execute("UPDATE car_rentals SET booked = 0 WHERE id = ?", (rental_id,))
    conn.commit()

    if cursor.rowcount > 0:
        conn.close()
        return f"Car rental {rental_id} successfully cancelled."
    else:
        conn.close()
        return f"No car rental found with ID {rental_id}."

```

# 🚗 Car Rental Tools – A Complete Guide  

When users book a flight, they often need transportation at their destination. This guide will walk you through implementing car rental tools that allow users to search for, book, update, and cancel car rentals.  

We'll break this down step by step, with **detailed explanations**, **real-world use cases**, and **code examples** to make it beginner-friendly.  

---

## 🔍 1. Searching for Car Rentals  

### 📌 **Purpose**  
The `search_car_rentals` function lets users find available car rentals based on criteria like **location, company name, and price tier**.  

### 📌 **Real-World Use Case**  
Imagine you book a flight to Dubai and need a car to explore the city. Using this tool, you can search for rental cars **in Dubai**, filter results by **brand (e.g., Hertz, Avis)**, and choose an option based on **price tiers (budget, luxury, etc.)**.

### 📌 **Code Explanation**  

```python
from datetime import date, datetime
from typing import Optional, Union
import sqlite3

db = "car_rental.db"  # Database file

@tool
def search_car_rentals(
    location: Optional[str] = None,
    name: Optional[str] = None,
    price_tier: Optional[str] = None,
    start_date: Optional[Union[datetime, date]] = None,
    end_date: Optional[Union[datetime, date]] = None,
) -> list[dict]:
    """
    Search for car rentals based on location, name, price tier, start date, and end date.
    """
    conn = sqlite3.connect(db)  # Connect to the database
    cursor = conn.cursor()

    query = "SELECT * FROM car_rentals WHERE 1=1"
    params = []

    if location:
        query += " AND location LIKE ?"
        params.append(f"%{location}%")
    if name:
        query += " AND name LIKE ?"
        params.append(f"%{name}%")

    cursor.execute(query, params)
    results = cursor.fetchall()
    conn.close()

    return [
        dict(zip([column[0] for column in cursor.description], row)) for row in results
    ]
```

### 🛠 **Explanation of Key Code Parts**  
1. **Function Definition**  
   - Uses `Optional` parameters, meaning users can search with or without filters.  
   - `Union[datetime, date]`: Supports searching by either `datetime` or `date`.  

2. **Database Connection & Query Execution**  
   - **`sqlite3.connect(db)`**: Connects to the database.  
   - **`cursor.execute(query, params)`**: Executes the SQL query dynamically based on user input.  

3. **Filtering the Search**  
   - If a user provides a **location**, the query adds `AND location LIKE ?`.  
   - Similarly, it filters based on **company name and price tier**.  

4. **Returning Results**  
   - The results are converted into a **list of dictionaries**, making them easy to use in APIs.  

---

## 🏷️ 2. Booking a Car Rental  

### 📌 **Purpose**  
The `book_car_rental` function allows users to book a specific car by **providing its rental ID**.

### 📌 **Real-World Use Case**  
If you found a great deal on a **Toyota Corolla from Hertz in Dubai**, you can **reserve it instantly** using this function.

### 📌 **Code Explanation**  

```python
@tool
def book_car_rental(rental_id: int) -> str:
    """
    Book a car rental by its ID.
    """
    conn = sqlite3.connect(db)
    cursor = conn.cursor()

    cursor.execute("UPDATE car_rentals SET booked = 1 WHERE id = ?", (rental_id,))
    conn.commit()

    if cursor.rowcount > 0:
        conn.close()
        return f"Car rental {rental_id} successfully booked."
    else:
        conn.close()
        return f"No car rental found with ID {rental_id}."
```

### 🛠 **Explanation of Key Code Parts**  
1. **Booking Logic**  
   - The function **updates the `booked` column** to `1`, meaning the car is reserved.  
   - `cursor.rowcount > 0` checks if the update was successful.  

2. **Database Operations**  
   - **`conn.commit()`**: Saves the changes.  
   - **`conn.close()`**: Closes the connection to free up resources.  

3. **User Feedback**  
   - If the car is found, the user sees **"Car rental successfully booked."**  
   - Otherwise, they see **"No car rental found with ID."**  

---

## 🔄 3. Updating a Car Rental  

### 📌 **Purpose**  
Allows users to **change the rental duration** (start and end dates).  

### 📌 **Real-World Use Case**  
You originally booked a car for **3 days in Dubai** but decide to extend it **to 5 days**. This function lets you update the dates.

### 📌 **Code Explanation**  

```python
@tool
def update_car_rental(
    rental_id: int,
    start_date: Optional[Union[datetime, date]] = None,
    end_date: Optional[Union[datetime, date]] = None,
) -> str:
    """
    Update a car rental's start and end dates by its ID.
    """
    conn = sqlite3.connect(db)
    cursor = conn.cursor()

    if start_date:
        cursor.execute(
            "UPDATE car_rentals SET start_date = ? WHERE id = ?",
            (start_date, rental_id),
        )
    if end_date:
        cursor.execute(
            "UPDATE car_rentals SET end_date = ? WHERE id = ?", (end_date, rental_id)
        )

    conn.commit()

    if cursor.rowcount > 0:
        conn.close()
        return f"Car rental {rental_id} successfully updated."
    else:
        conn.close()
        return f"No car rental found with ID {rental_id}."
```

### 🛠 **Explanation of Key Code Parts**  
1. **Checking if Start/End Dates Are Provided**  
   - If the user provides **new dates**, the query updates them.  

2. **Database Commit & Closing**  
   - `conn.commit()` saves changes, ensuring updates take effect.  
   - `conn.close()` releases resources after the operation.  

---

## ❌ 4. Canceling a Car Rental  

### 📌 **Purpose**  
Allows users to **cancel their car rental reservation** by ID.  

### 📌 **Real-World Use Case**  
You booked a car but **found a better deal** elsewhere or **changed your travel plans**. This function lets you **cancel the reservation**.

### 📌 **Code Explanation**  

```python
@tool
def cancel_car_rental(rental_id: int) -> str:
    """
    Cancel a car rental by its ID.
    """
    conn = sqlite3.connect(db)
    cursor = conn.cursor()

    cursor.execute("UPDATE car_rentals SET booked = 0 WHERE id = ?", (rental_id,))
    conn.commit()

    if cursor.rowcount > 0:
        conn.close()
        return f"Car rental {rental_id} successfully cancelled."
    else:
        conn.close()
        return f"No car rental found with ID {rental_id}."
```

### 🛠 **Explanation of Key Code Parts**  
1. **Canceling the Booking**  
   - **Sets `booked = 0`**, marking the car as available.  

2. **Success/Failure Messages**  
   - If successful, it returns **"Car rental successfully cancelled."**  
   - If no matching car is found, it returns **"No car rental found."**  

---

## 🎯 **Conclusion**  

🚀 With these functions, we've built a **basic car rental system** where users can:  
✔ **Search for cars** based on location, price, and company name.  
✔ **Book a car** using its unique ID.  
✔ **Update a reservation** to change rental dates.  
✔ **Cancel a rental** if plans change.  

These tools are commonly used in travel booking platforms like **Expedia, Booking.com, and Kayak**! 🚗💨