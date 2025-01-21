import sys

def decode_hex(hex_string):
    # Remove whitespace and newlines
    hex_string = ''.join(hex_string.split())
    
    # Convert to bytes
    decoded = ''
    i = 0
    pos = 0
    
    while i < len(hex_string):
        # Take 4 characters (2 bytes) at a time due to endianness
        hex_bytes = hex_string[i:i+4]
        if not hex_bytes:
            break
            
        # Convert considering little endian
        byte1 = int(hex_bytes[2:4], 16)
        byte2 = int(hex_bytes[0:2], 16)
        
        # Decode each byte by subtracting its position
        char1 = chr(byte1 - pos)
        char2 = chr(byte2 - (pos + 1))
        
        decoded += char1 + char2
        
        i += 4
        pos += 2
    
    return decoded

# Your hexdump
hex_input = """
3466 6d6b 366d 7c70 823d 707f 6e82 8283
4244 4483 7b75 8c7f 89
"""

result = decode_hex(hex_input)
print("Decoded string:", result)