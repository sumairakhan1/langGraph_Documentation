# Hotels¶
The user has to sleep! Define some tools to search for and manage hotel reservations.

```python
@tool
def search_hotels(
    location: Optional[str] = None,
    name: Optional[str] = None,
    price_tier: Optional[str] = None,
    checkin_date: Optional[Union[datetime, date]] = None,
    checkout_date: Optional[Union[datetime, date]] = None,
) -> list[dict]:
    """
    Search for hotels based on location, name, price tier, check-in date, and check-out date.

    Args:
        location (Optional[str]): The location of the hotel. Defaults to None.
        name (Optional[str]): The name of the hotel. Defaults to None.
        price_tier (Optional[str]): The price tier of the hotel. Defaults to None. Examples: Midscale, Upper Midscale, Upscale, Luxury
        checkin_date (Optional[Union[datetime, date]]): The check-in date of the hotel. Defaults to None.
        checkout_date (Optional[Union[datetime, date]]): The check-out date of the hotel. Defaults to None.

    Returns:
        list[dict]: A list of hotel dictionaries matching the search criteria.
    """
    conn = sqlite3.connect(db)
    cursor = conn.cursor()

    query = "SELECT * FROM hotels WHERE 1=1"
    params = []

    if location:
        query += " AND location LIKE ?"
        params.append(f"%{location}%")
    if name:
        query += " AND name LIKE ?"
        params.append(f"%{name}%")
    # For the sake of this tutorial, we will let you match on any dates and price tier.
    cursor.execute(query, params)
    results = cursor.fetchall()

    conn.close()

    return [
        dict(zip([column[0] for column in cursor.description], row)) for row in results
    ]


@tool
def book_hotel(hotel_id: int) -> str:
    """
    Book a hotel by its ID.

    Args:
        hotel_id (int): The ID of the hotel to book.

    Returns:
        str: A message indicating whether the hotel was successfully booked or not.
    """
    conn = sqlite3.connect(db)
    cursor = conn.cursor()

    cursor.execute("UPDATE hotels SET booked = 1 WHERE id = ?", (hotel_id,))
    conn.commit()

    if cursor.rowcount > 0:
        conn.close()
        return f"Hotel {hotel_id} successfully booked."
    else:
        conn.close()
        return f"No hotel found with ID {hotel_id}."


@tool
def update_hotel(
    hotel_id: int,
    checkin_date: Optional[Union[datetime, date]] = None,
    checkout_date: Optional[Union[datetime, date]] = None,
) -> str:
    """
    Update a hotel's check-in and check-out dates by its ID.

    Args:
        hotel_id (int): The ID of the hotel to update.
        checkin_date (Optional[Union[datetime, date]]): The new check-in date of the hotel. Defaults to None.
        checkout_date (Optional[Union[datetime, date]]): The new check-out date of the hotel. Defaults to None.

    Returns:
        str: A message indicating whether the hotel was successfully updated or not.
    """
    conn = sqlite3.connect(db)
    cursor = conn.cursor()

    if checkin_date:
        cursor.execute(
            "UPDATE hotels SET checkin_date = ? WHERE id = ?", (checkin_date, hotel_id)
        )
    if checkout_date:
        cursor.execute(
            "UPDATE hotels SET checkout_date = ? WHERE id = ?",
            (checkout_date, hotel_id),
        )

    conn.commit()

    if cursor.rowcount > 0:
        conn.close()
        return f"Hotel {hotel_id} successfully updated."
    else:
        conn.close()
        return f"No hotel found with ID {hotel_id}."


@tool
def cancel_hotel(hotel_id: int) -> str:
    """
    Cancel a hotel by its ID.

    Args:
        hotel_id (int): The ID of the hotel to cancel.

    Returns:
        str: A message indicating whether the hotel was successfully cancelled or not.
    """
    conn = sqlite3.connect(db)
    cursor = conn.cursor()

    cursor.execute("UPDATE hotels SET booked = 0 WHERE id = ?", (hotel_id,))
    conn.commit()

    if cursor.rowcount > 0:
        conn.close()
        return f"Hotel {hotel_id} successfully cancelled."
    else:
        conn.close()
        return f"No hotel found with ID {hotel_id}."

```

# 🏨 **Hotel Reservation Tools**  

When users plan a trip, booking a hotel is just as important as booking a flight. Let’s explore how we can create tools to help users search, book, update, and cancel hotel reservations.  

I’ll break down each concept with:  
- ✅ **Detailed explanations**  
- 🛠️ **Real-world examples**  
- 💡 **Code examples with step-by-step explanations**  
- 🌟 **Easy-to-understand logic for beginners**  

---

## 🌍 **Real-World Use Case**  
Imagine you are building a travel booking website like **Booking.com** or **Agoda**.  
Users search for hotels, reserve rooms, modify booking dates, or cancel reservations if plans change.  

---

## 🔍 **1. Search Hotels**  
### ✅ **Purpose:**  
Allow users to search for hotels based on specific preferences such as location, price tier, and dates.  

### 💻 **Code Explanation (Step-by-Step):**  

```python
from datetime import date, datetime
from typing import Optional, Union
import sqlite3

db = "hotel_database.db"  # Example database file
```
- 🔗 **Imports**:  
  - `datetime` & `date`: Handle check-in and check-out dates.  
  - `Optional` & `Union`: Specify that some parameters can be empty.  
  - `sqlite3`: For connecting and interacting with a **SQLite** database.  

---

### 💾 **Search Function:**

```python
@tool
def search_hotels(
    location: Optional[str] = None,
    name: Optional[str] = None,
    price_tier: Optional[str] = None,
    checkin_date: Optional[Union[datetime, date]] = None,
    checkout_date: Optional[Union[datetime, date]] = None,
) -> list[dict]:
```
- 🏷️ **Function Arguments:**  
  - `location`: Where the user wants to stay.  
  - `name`: Specific hotel name (if any).  
  - `price_tier`: Budget preference like **Midscale**, **Luxury**, etc.  
  - `checkin_date` & `checkout_date`: Desired stay period.  

---

### 🔎 **SQL Query & Search Logic:**  

```python
    conn = sqlite3.connect(db)
    cursor = conn.cursor()

    query = "SELECT * FROM hotels WHERE 1=1"
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

### 🔍 **What’s Happening Here?**  
- ✅ **Connect to the database:** `conn = sqlite3.connect(db)`  
- 🧮 **Dynamic SQL Query:** The query adds conditions **only** if parameters are provided.  
- 🧩 **LIKE operator:** Searches for partial matches (useful for flexible searches).  
- 🏗️ **Fetch results:** `fetchall()` grabs all matching rows.  
- 📦 **Format results:** Converts data into a list of dictionaries, making it easier to use later.  

---

### 💡 **Example Usage:**  
```python
hotels = search_hotels(location="Karachi", price_tier="Luxury")
print(hotels)
```
**🔎 Output:**  
```python
[
    {"id": 1, "name": "Luxury Stay Karachi", "location": "Karachi", "price_tier": "Luxury", "booked": 0},
    {"id": 2, "name": "Seaside Luxury Resort", "location": "Karachi", "price_tier": "Luxury", "booked": 0}
]
```
---

## 📅 **2. Book a Hotel**  
### ✅ **Purpose:**  
Reserve a hotel room by changing its **booked** status in the database.  

### 💻 **Code & Explanation:**
```python
@tool
def book_hotel(hotel_id: int) -> str:
    conn = sqlite3.connect(db)
    cursor = conn.cursor()

    cursor.execute("UPDATE hotels SET booked = 1 WHERE id = ?", (hotel_id,))
    conn.commit()

    if cursor.rowcount > 0:
        conn.close()
        return f"Hotel {hotel_id} successfully booked."
    else:
        conn.close()
        return f"No hotel found with ID {hotel_id}."
```

### 💬 **What’s Happening?**  
- 🔗 **Connect** to the database.  
- 📝 **Update Query:** Changes the `booked` field to `1` (which means **booked**).  
- 🎯 **rowcount:** Checks if the update affected any rows.  
- 🏁 **Return Success/Failure:** Returns appropriate messages based on results.  

---

### 💡 **Example Usage:**  
```python
print(book_hotel(1))
```
**🔍 Output:**  
```
Hotel 1 successfully booked.
```

---

## 🔄 **3. Update Hotel Booking**  
### ✅ **Purpose:**  
Modify the check-in and check-out dates for an existing reservation.  

### 💻 **Code & Explanation:**  
```python
@tool
def update_hotel(
    hotel_id: int,
    checkin_date: Optional[Union[datetime, date]] = None,
    checkout_date: Optional[Union[datetime, date]] = None,
) -> str:
    conn = sqlite3.connect(db)
    cursor = conn.cursor()

    if checkin_date:
        cursor.execute(
            "UPDATE hotels SET checkin_date = ? WHERE id = ?", (checkin_date, hotel_id)
        )
    if checkout_date:
        cursor.execute(
            "UPDATE hotels SET checkout_date = ? WHERE id = ?", (checkout_date, hotel_id)
        )

    conn.commit()

    if cursor.rowcount > 0:
        conn.close()
        return f"Hotel {hotel_id} successfully updated."
    else:
        conn.close()
        return f"No hotel found with ID {hotel_id}."
```

### 📝 **What’s Happening?**  
- 📅 **Flexible Updates:** Only updates the dates provided by the user.  
- 🔄 **Dynamic SQL:** Ensures only non-empty fields are updated.  
- 🎯 **rowcount Check:** Verifies if the update was successful.  

---

### 💡 **Example Usage:**  
```python
print(update_hotel(1, checkin_date="2024-12-01", checkout_date="2024-12-10"))
```
**🔍 Output:**  
```
Hotel 1 successfully updated.
```

---

## ❌ **4. Cancel Hotel Booking**  
### ✅ **Purpose:**  
Allow users to cancel reservations by updating the **booked** status.  

### 💻 **Code & Explanation:**  
```python
@tool
def cancel_hotel(hotel_id: int) -> str:
    conn = sqlite3.connect(db)
    cursor = conn.cursor()

    cursor.execute("UPDATE hotels SET booked = 0 WHERE id = ?", (hotel_id,))
    conn.commit()

    if cursor.rowcount > 0:
        conn.close()
        return f"Hotel {hotel_id} successfully cancelled."
    else:
        conn.close()
        return f"No hotel found with ID {hotel_id}."
```

### 🔍 **What’s Happening?**  
- 🔓 **Reset Booking Status:** Updates `booked` back to `0`, meaning **available** again.  
- 🏃 **Fast Checks:** Uses `rowcount` to confirm cancellation.  

---

### 💡 **Example Usage:**  
```python
print(cancel_hotel(1))
```
**🔍 Output:**  
```
Hotel 1 successfully cancelled.
```

---

## 🌟 **Conclusion**  
✨ We built **four powerful tools** for hotel reservations:  
- 🔎 **Search Hotels:** Flexible searches by location, name, and price tier.  
- 🏨 **Book a Hotel:** Reserves the desired hotel.  
- 📝 **Update Reservation:** Modifies booking dates as needed.  
- ❌ **Cancel Booking:** Frees up rooms when plans change.  

💡 **Real-World Impact:**  
These tools mimic how apps like **Airbnb**, **Booking.com**, and **Expedia** work behind the scenes, handling thousands of hotel bookings daily.  

Let me know if you want more advanced concepts like **user authentication** or **payment integration**! 🌐✨