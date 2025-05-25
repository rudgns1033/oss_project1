#include <iostream>
#include <stack>
#include <string>
#include <cctype>
#include <cstdlib>
using namespace std;

double applyOp(double a, double b, char op) {
    switch(op) {
        case '+': return a + b;
        case '-': return a - b;
        case '*': return a * b;
        case '/': if(b == 0) { cerr << "error" << endl; exit(1); } return a / b;
    }
    return 0;
}

int precedence(char op) {
    if(op == '+' || op == '-') return 1;
    if(op == '*' || op == '/') return 2;
    return 0;
}

int main() {
    string expr;
    while (getline(cin, expr)) {
        stack<double> values;
        stack<char> ops;
        bool expect_unary = true;
        for (size_t i = 0; i < expr.size(); ++i) {
            char c = expr[i];
            if (isspace(c)) continue;

            if (isdigit(c) || c == '.') {
                double num = strtod(expr.c_str()+i, nullptr);
                values.push(num);
                // advance i past number
                while (i < expr.size() && (isdigit(expr[i]) || expr[i] == '.')) i++;
                i--;
                expect_unary = false;

            } else if (c == '(') {
                ops.push(c);
                expect_unary = true;

            } else if (c == ')') {
                while (!ops.empty() && ops.top() != '(') {
                    double b = values.top(); values.pop();
                    double a = values.top(); values.pop();
                    char op = ops.top(); ops.pop();
                    values.push(applyOp(a, b, op));
                }
                if (!ops.empty()) ops.pop();  // pop '('
                expect_unary = false;

            } else if (c=='+'||c=='-'||c=='*'||c=='/') {
                char op = c;
                if (expect_unary && c == '-') {
                    // unary minus, treat as 0 - value
                    values.push(0);
                }
                while (!ops.empty() && precedence(ops.top()) >= precedence(op)) {
                    double b = values.top(); values.pop();
                    double a = values.top(); values.pop();
                    char prev = ops.top(); ops.pop();
                    values.push(applyOp(a, b, prev));
                }
                ops.push(op);
                expect_unary = true;

            } else {
                // invalid char
                cerr << "error" << endl;
                exit(1);
            }
        }

        while (!ops.empty()) {
            double b = values.top(); values.pop();
            double a = values.top(); values.pop();
            char op = ops.top(); ops.pop();
            values.push(applyOp(a, b, op));
        }

        if (!values.empty()) cout << values.top() << endl;
    }
    return 0;
}
