import sys

input_file = sys.argv[1]
output_file = sys.argv[2]

with open(input_file, 'rb') as f:
    data = f.read()
    
with open(output_file, 'w') as f:
    for i in range(0, len(data), 4):
        word = data[i:i+4]
        val = int.from_bytes(word, 'little')
        f.write(f'{val:08x}\n')
