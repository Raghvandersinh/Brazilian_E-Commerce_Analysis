import pandas as pd
from deep_translator import GoogleTranslator
import time

def translate_batch(texts, batch_size=50):
    """Translate a batch of texts"""
    translator = GoogleTranslator(source='auto', target='en')
    results = []
    
    for i, text in enumerate(texts):
        try:
            # Handle empty values
            if pd.isna(text) or text == '' or text == ' ':
                results.append('')
            else:
                # Translate
                translated = translator.translate(text)
                results.append(translated)
                
            # Add delay between translations
            time.sleep(0.3)
            
        except Exception as e:
            results.append(f"Error: {e}")
    
    return results

# Read CSV
df = pd.read_csv('data/queried_data/Product_Review.csv')

# Process in batches
batch_size = 10
total_rows = len(df)
translations = []

print(f"Starting translation of {total_rows} rows...")

for i in range(0, total_rows, batch_size):
    # Get batch
    batch_end = min(i + batch_size, total_rows)
    batch = df.iloc[i:batch_end]
    
    print(f"Translating batch {i//batch_size + 1}/{(total_rows-1)//batch_size + 1} (rows {i+1}-{batch_end})")
    
    # Translate batch
    translated_batch = translate_batch(batch['review_comment_message'].tolist())
    translations.extend(translated_batch)

# Add translations to dataframe
df['review_comment_message_eng'] = translations

# Save
df.to_csv('data/queried_data/Product_Reviews_Eng.csv', index=False)
print("✅ Translation complete!")