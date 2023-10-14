import torch
import torch.nn.functional as F

import warnings
warnings.filterwarnings('ignore')


def generate_proba(scores, tokens, processor):
    """
    Calculates the confidence of the model in predicting a particular token
    :param scores: logits
    :param tokens: predictions
    :param processor: model's processor
    :return: dict, particular token and it's probability; float, average proba for all tokens
    """
    tok2prob = {}
    average_proba = .0
    for token, proba in zip(tokens[0][1:-1], scores[:-1]):
        tok_proba = torch.max(F.softmax(proba[0])).item()
        average_proba += tok_proba
        tok2prob[processor.tokenizer.decode([token])] = round(tok_proba, 3)

    return tok2prob, round(average_proba / len(scores[:-1]), 4) * 100


def is_proper(number: str) -> bool:
    """
    Checker for train's numbers
    :param number: recognized numver
    :return: bool, is number correct
    """
    transformation = lambda x: x // 10 + x % 10
    number, last_number = number[:-1], int(number[-1])
    odds = number[::2]
    evens = number[1::2]

    odds = [transformation(int(odd) * 2) for odd in odds]
    evens = [int(even) for even in evens]

    return (sum(odds) + sum(evens) + last_number) % 10 == 0
