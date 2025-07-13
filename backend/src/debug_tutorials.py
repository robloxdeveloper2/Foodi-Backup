#!/usr/bin/env python3
"""
Debug script to test tutorial queries
"""

import sys
import os

# Add the src directory to Python path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from main import create_app
from data_access.database import db
from core.models.tutorial import Tutorial
from data_access.tutorial_repository import TutorialRepository

def main():
    # Create Flask app and context
    app = create_app()
    
    with app.app_context():
        try:
            # Rollback any failed transactions
            db.session.rollback()
            print("✓ Transaction rolled back")
            
            # Test direct query
            count = db.session.query(Tutorial).count()
            print(f"✓ Total tutorials in database: {count}")
            
            # Test active tutorials
            active_count = db.session.query(Tutorial).filter(Tutorial.is_active == True).count()
            print(f"✓ Active tutorials: {active_count}")
            
            # Test featured tutorials
            featured_count = db.session.query(Tutorial).filter(Tutorial.is_featured == True).count()
            print(f"✓ Featured tutorials: {featured_count}")
            
            # Test beginner tutorials
            beginner_count = db.session.query(Tutorial).filter(Tutorial.is_beginner_friendly == True).count()
            print(f"✓ Beginner tutorials: {beginner_count}")
            
            # Show first few tutorials
            if count > 0:
                tutorials = db.session.query(Tutorial).limit(3).all()
                print("\nFirst 3 tutorials:")
                for t in tutorials:
                    print(f"  - ID: {t.id}, Title: {t.title}")
                    print(f"    Active: {t.is_active}, Featured: {t.is_featured}, Beginner: {t.is_beginner_friendly}")
            
            # Test repository methods
            print("\n--- Testing Repository Methods ---")
            repo = TutorialRepository()
            
            # Test search with empty term
            try:
                tutorials, total = repo.search_tutorials("", {}, limit=5)
                print(f"✓ Search (empty): {len(tutorials)} tutorials, total: {total}")
            except Exception as e:
                print(f"✗ Search error: {e}")
            
            # Test featured
            try:
                featured = repo.get_featured_tutorials(5)
                print(f"✓ Featured: {len(featured)} tutorials")
            except Exception as e:
                print(f"✗ Featured error: {e}")
            
            # Test beginner
            try:
                beginner = repo.get_beginner_friendly_tutorials(5)
                print(f"✓ Beginner: {len(beginner)} tutorials")
            except Exception as e:
                print(f"✗ Beginner error: {e}")
                
        except Exception as e:
            print(f"✗ Error: {e}")
            import traceback
            traceback.print_exc()

if __name__ == "__main__":
    main() 