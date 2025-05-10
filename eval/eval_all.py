from json2file import read_jsonl, json2file
from save2file import save2file,save2file_with_tempdir
from excute import excute
from extract import extract
import json
import os 
import argparse
from excute import get_awk_ans
import glob
import traceback
import tempfile
import shutil
import random 
import multiprocessing
import uuid

def get_data_dirs_for_lang(lang):
    # Map language to data subdirs needed for that language
    # Expand as needed for your dataset
    mapping = {
        'AWK': ['AWK'],
        'C#': ['C#'],
        'Common Lisp': ['Common Lisp'],
        'F#': ['F#'],
        'rust': ['rust'],
        'go': ['go'],
        'HTML': ['HTML'],
        'JSON': ['JSON'],
        'Markdown': ['Markdown'],
        'Visual Basic': ['Visual Basic'],
        # Add more as needed
    }
    return mapping.get(lang, [lang])

def run_single_test(args_tuple):
    item, lang, result_path = args_tuple
    temp_dir = f"/tmp/mceval_{uuid.uuid4()}"
    os.makedirs(temp_dir, exist_ok=True)
    # Copy only the needed data dirs
    for subdir in get_data_dirs_for_lang(lang):
        src = os.path.join(os.path.dirname(result_path), 'data', subdir)
        dst = os.path.join(temp_dir, subdir)
        if os.path.exists(src):
            shutil.copytree(src, dst, dirs_exist_ok=True)
    # Special handling for AWK reference output
    if lang == 'AWK':
        try:
            get_awk_ans(item, temp_dir)
        except Exception:
            pass
    try:
        code = extract(item["raw_generation"][0], item, lang)
    except Exception:
        code = "1234"
    if code is None:
        code = "1234"
    try:
        path, _, _ = save2file_with_tempdir(content=code, language_type=lang, item=item, temp_dir=temp_dir)
        passed = excute(lang, path, item["task_id"], temp_dir=temp_dir)
    except Exception:
        passed = False
    # Clean up temp dir
    shutil.rmtree(temp_dir, ignore_errors=True)
    return {"task_id": item["task_id"], "sample": item.get("sample", 0), "pass": passed}

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--result_path', type=str, default='../results')
    parser.add_argument('--output_path', type=str, default='../tmp_eval_out')
    args = parser.parse_args()
    jobs = []
    for fname in os.listdir(args.result_path):
        if not fname.endswith('.jsonl'):
            continue
        lang = fname.split('.')[0]
        with open(os.path.join(args.result_path, fname)) as f:
            for line in f:
                if line.strip():
                    item = json.loads(line)
                    jobs.append((item, lang, args.result_path))
    with multiprocessing.Pool() as pool:
        results = pool.map(run_single_test, jobs)
    with open(args.output_path, 'w') as f:
        for res in results:
            f.write(json.dumps(res) + '\n')


if __name__ == '__main__':
    main()
