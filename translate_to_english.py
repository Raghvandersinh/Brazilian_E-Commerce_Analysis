import pandas as pd
from deep_translator import GoogleTranslator
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
import threading
from queue import Queue
import numpy as np

# Thread-local storage for translators
thread_local = threading.local()

def get_translator():
    """Get or create a thread-local translator instance"""
    if not hasattr(thread_local, "translator"):
        thread_local.translator = GoogleTranslator(source='auto', target='en')
    return thread_local.translator

def translate_single_text(text):
    """Translate a single text"""
    if pd.isna(text) or text == '' or text == ' ':
        return ''
    
    try:
        translator = get_translator()
        return translator.translate(text)
    except Exception as e:
        return f"Error: {e}"

def translate_batch_parallel(texts, batch_size=50, max_workers=5):
    """Translate a batch of texts using multiple threads"""
    results = [None] * len(texts)
    
    # Process texts in smaller chunks for better thread distribution
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        # Submit all translation tasks
        future_to_index = {
            executor.submit(translate_single_text, text): i 
            for i, text in enumerate(texts)
        }
        
        # Collect results as they complete
        for future in as_completed(future_to_index):
            idx = future_to_index[future]
            try:
                results[idx] = future.result()
            except Exception as e:
                results[idx] = f"Error: {e}"
    
    return results

def translate_batch_with_delay(texts, batch_size=50, max_workers=5, delay=0.05):
    """Translate texts with parallel processing and rate limiting"""
    translator = GoogleTranslator(source='auto', target='en')
    results = [None] * len(texts)
    
    # Use a queue for rate limiting
    rate_limiter = Queue(maxsize=max_workers)
    
    def translate_with_delay(text, idx):
        with rate_limiter:  # This blocks if queue is full
            if pd.isna(text) or text == '' or text == ' ':
                results[idx] = ''
            else:
                try:
                    # Add small delay to avoid rate limits
                    time.sleep(delay)
                    results[idx] = translator.translate(text)
                except Exception as e:
                    results[idx] = f"Error: {e}"
    
    # Create threads
    threads = []
    for i, text in enumerate(texts):
        thread = threading.Thread(target=translate_with_delay, args=(text, i))
        threads.append(thread)
        thread.start()
        
        # Limit concurrent threads
        if len(threads) >= max_workers:
            for t in threads:
                t.join()
            threads = []
    
    # Wait for remaining threads
    for t in threads:
        t.join()
    
    return results

def process_batch_with_threads(df_batch, max_workers=5):
    """Process a batch of rows with threading"""
    texts = df_batch['review_comment_message'].tolist()
    
    # Use parallel translation
    translated = translate_batch_parallel(texts, max_workers=max_workers)
    return translated

# Main execution
def main():
    # Read CSV
    print("Reading CSV file...")
    df = pd.read_csv('data/queried_data/Product_Review.csv')
    
    # Parameters
    batch_size = 50
    max_workers = 5  # Adjust based on your system and API limits
    total_rows = len(df)
    
    print(f"Starting translation of {total_rows} rows...")
    print(f"Using {max_workers} threads")
    
    # Process in batches with threading
    translations = []
    start_time = time.time()
    
    for i in range(0, total_rows, batch_size):
        batch_end = min(i + batch_size, total_rows)
        batch = df.iloc[i:batch_end]
        
        print(f"Translating batch {i//batch_size + 1}/{(total_rows-1)//batch_size + 1} (rows {i+1}-{batch_end})")
        
        # Translate batch with threading
        translated_batch = process_batch_with_threads(batch, max_workers=max_workers)
        translations.extend(translated_batch)
    
    # Add translations to dataframe
    df['review_comment_message_eng'] = translations
    
    # Save
    df.to_csv('data/queried_data/Product_Reviews_Eng.csv', index=False)
    
    elapsed_time = time.time() - start_time
    print(f"✅ Translation complete! Time taken: {elapsed_time:.2f} seconds")

if __name__ == "__main__":
    main()