import streamlit as st
import os
import glob
from app.utils import utils

def get_fonts_cache(font_dir):
    if 'fonts_cache' not in st.session_state:
        fonts = []
        for root, dirs, files in os.walk(font_dir):
            for file in files:
                if file.endswith((".ttf", ".ttc", ".otf")):
                    fonts.append(file)
        fonts.sort()
        
        if not fonts:
            fonts = ["SimHei", "Arial", "Helvetica", "DejaVu Sans"]
        
        st.session_state['fonts_cache'] = fonts
    return st.session_state['fonts_cache']

def get_video_files_cache():
    if 'video_files_cache' not in st.session_state:
        video_files = []
        for suffix in ["*.mp4", "*.mov", "*.avi", "*.mkv"]:
            video_files.extend(glob.glob(os.path.join(utils.video_dir(), suffix)))
        st.session_state['video_files_cache'] = video_files[::-1]
    return st.session_state['video_files_cache']

def get_songs_cache(song_dir):
    if 'songs_cache' not in st.session_state:
        songs = []
        for root, dirs, files in os.walk(song_dir):
            for file in files:
                if file.endswith(".mp3"):
                    songs.append(file)
        st.session_state['songs_cache'] = songs
    return st.session_state['songs_cache']

def clear_fonts_cache():
    if 'fonts_cache' in st.session_state:
        del st.session_state['fonts_cache']

def clear_songs_cache():
    if 'songs_cache' in st.session_state:
        del st.session_state['songs_cache'] 