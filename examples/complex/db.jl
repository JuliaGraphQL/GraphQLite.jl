carts = [
    Cart(1, "Frodo's Cart"),
    Cart(2, "Bilbo's Cart"),
    Cart(3, "Gandalf's Cart"),
]

customers = [
    Customer(1, "Frodo", 1),
    Customer(2, "Bilbo", 2),
]

items = [
    Item(1, "apple", ["maçã","apfel"], 1),
    Item(2, "banana", ["banana","banane"], 1),
    Item(3, "carrot", ["cenoura","karotte"], 2),
    Item(4, "fish", ["peixe","fisch"], 5),
    Item(5, "steak", ["bife","steak"], 5),
    Item(6, "roses", ["rosas","rosen"], 5),
]

cart_items = [
    CartItem(1, 1, 1),
    CartItem(2, 1, 2),
    CartItem(3, 1, 3),
    CartItem(4, 1, 4),
    CartItem(5, 2, 5),
    CartItem(6, 3, 6),
]

brands = [
    Brand(1, "Del Monte", 1),
    Brand(2, "Green Giant", 1),
    Brand(3, "Tyson", 2),
    Brand(4, "Purina", 2),
    Brand(5, "Harris Teeter", 3),
]

companies = [
    Company(1, "Acme A"),
    Company(2, "Acme B"),
    Company(3, "Acme C"),
]

categories = [
    Category(1, "fruit"),
    Category(2, "vegetable"),
    Category(3, "produce"),
    Category(4, "meat"),
    Category(5, "flowers"),
    Category(6, "perishable"),
    Category(7, "non-perishable"),
]

groups = [
    Group(1, "Group A"),
    Group(2, "Group B"),
]

cat_groups = [
    CatGroup(1, 2, 2),
    CatGroup(2, 3, 1),
    CatGroup(3, 3, 2),
    CatGroup(4, 6, 1),
    CatGroup(5, 6, 2),
    CatGroup(6, 7, 2),
]

item_categories = [
    ItemCategory(1, 1, 1),
    ItemCategory(2, 1, 6),
    ItemCategory(3, 2, 1),
    ItemCategory(4, 2, 6),
    ItemCategory(5, 3, 2),
    ItemCategory(6, 3, 6),
    ItemCategory(7, 4, 4),
    ItemCategory(8, 4, 6),
    ItemCategory(9, 5, 4),
    ItemCategory(10, 5, 6),
    ItemCategory(11, 6, 5),
    ItemCategory(12, 6, 6),
    ItemCategory(13, 1, 3),
    ItemCategory(14, 2, 3),
    ItemCategory(15, 3, 3),
]

