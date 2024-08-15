filename = "pokemon_forms_Gen_9_Pack.txt"
total_cap = 600  # new total cap
factor_cap = 1.5  # new factor cap
max_value = 255

def calculate_new_values(nums, total_cap, factor_cap):
    total = sum(nums)
    if total < total_cap:
        factor = min(total_cap / total, factor_cap)
        new_nums = [int(min(num * factor, max_value)) for num in nums]
    else:
        new_nums = nums
    return new_nums

with open(filename, "r") as f:
    lines = f.readlines()

for i in range(len(lines)):
    line = lines[i]
    if line.startswith("BaseStats = "):
        nums = line.split("=")[1].strip().split(",")
        try:
            nums = [float(num) for num in nums]
            first_num = int(nums[0])  # Store the first number before modifying
            new_nums = calculate_new_values(nums[1:], total_cap, factor_cap)
            new_line = "BaseStats = " + str(first_num) + "," + ",".join(map(str, new_nums)) + "\n"
            lines[i] = new_line
        except ValueError:
            # Handle invalid input format gracefully
            pass

with open("output.txt", "w") as f:
    f.writelines(lines)