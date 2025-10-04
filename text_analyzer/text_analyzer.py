file_path = "my_document.txt"
try:
    with open(file_path, 'r') as file:
         lines = file.readlines()
         chars = sum(len(line) for line in lines)
         empty_lines = sum(1 for line in lines if not len(line.strip()))
         char_frequency = {}
         for line in lines:
             for char in line:
                 if char in char_frequency:
                     char_frequency[char] += 1
                 else:
                     char_frequency[char] = 1
         user_input = input("Enter symbols corresponding to data you want to see: 1 for number of lines, 2 for number of characters, 3 for number of empty lines, 4 for character frequency: ")
         if user_input.find("1") != -1:
            print(f"Number of lines: {len(lines)}")
         if user_input.find("2") != -1:
            print(f"Number of characters: {chars}")
         if user_input.find("3") != -1:
            print(f"Number of empty lines: {empty_lines}")
         if user_input.find("4") != -1:
            print("Character frequency:")        
            for char, count in char_frequency.items():
                print(f"{char}: {count}")
except Exception as e:
    print(f"An error occurred: {e}")