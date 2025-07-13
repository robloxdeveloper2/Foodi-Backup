#!/usr/bin/env python3
"""
Script to check tutorial data and rollback any failed transactions
"""

import sys
import os

# Add the src directory to Python path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from data_access.database import db
from core.models.tutorial import Tutorial

def main():
    try:
        # Rollback any failed transactions
        db.session.rollback()
        print("✓ Transaction rolled back")
        
        # Check tutorial count
        count = db.session.query(Tutorial).count()
        print(f"✓ Tutorial count: {count}")
        
        if count > 0:
            # Show first few tutorials
            tutorials = db.session.query(Tutorial).limit(5).all()
            print("\nTutorials in database:")
            for t in tutorials:
                print(f"  - {t.id}: {t.title} ({t.category})")
        else:
            print("⚠ No tutorials found in database")
            
    except Exception as e:
        print(f"✗ Error: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main() 