#!/usr/bin/env python

import argparse
import matplotlib.pyplot as plt


def main(args):
    models = ["LSTM", "LightConv", "CNN"]
    
    plt.figure(1, figsize=[5.,4])
    plt.title("Model WER Comparison")
    plt.xlabel("epochs")
    plt.ylabel("WER")

    for tag, file in zip(models, args.files):
        wer_prog = []
        with open(file, "r") as source:
            best = 1
            for line in source:
                score = line.rstrip()
                if score:
                    best = min(float(score), best)
                    wer_prog.append(best)
        epochs = [i + 1 for i in range(len(wer_prog))]
        plt.plot(epochs, wer_prog, label=tag)
    plt.legend()
    plt.savefig(f"results/Model_WER_Comparison-{args.set}.png")        


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "files",
        nargs="+",
        help="file or list of files to plot"
    )
    parser.add_argument(
        "--set",
        type=str
    )
    main(parser.parse_args())
