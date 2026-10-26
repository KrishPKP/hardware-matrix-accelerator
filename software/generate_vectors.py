import random

N = 4
NUM_TESTS = 5


def matmul(A, B):
    n = len(A)
    C = [[0 for _ in range(n)] for _ in range(n)]

    for i in range(n):
        for j in range(n):
            for k in range(n):
                C[i][j] += A[i][k] * B[k][j]

    return C


if __name__ == "__main__":

    with open("A.txt", "w") as a_file, \
         open("B.txt", "w") as b_file, \
         open("expected.txt", "w") as expected_file:

        for test in range(NUM_TESTS):

            A = [
                [random.randint(0, 255) for _ in range(N)]
                for _ in range(N)
            ]

            B = [
                [random.randint(0, 255) for _ in range(N)]
                for _ in range(N)
            ]

            C = matmul(A, B)
            flat_A = [value for row in A for value in row]
            flat_B = [value for row in B for value in row]
            flat_C = [value for row in C for value in row]

            #write the matrices
            a_file.write(" ".join(map(str, flat_A)) + "\n")
            b_file.write(" ".join(map(str, flat_B)) + "\n")
            expected_file.write(" ".join(map(str, flat_C)) + "\n")