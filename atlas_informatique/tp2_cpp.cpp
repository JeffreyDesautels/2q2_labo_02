#include <iostream>
#include <locale.h>
#include <conio.h>
#include <fstream>
#include <string>

using namespace std;

const string NOM_FICHIER = "products.dat";

struct Produit {
    string compagnie;
    string objet;
    string commentaire;
    float prix;
};

void display_product(Produit produit) {
    cout << endl << endl;
    cout << produit.compagnie << " - ";
    cout << produit.objet << endl;
    cout << produit.commentaire << endl;
    cout << produit.prix << "$";
}

void display_error() {
    cout << endl << endl;
    cout << "Produit non trouvé !";
}

void file_search(string& buffer) {
    ifstream fichier(NOM_FICHIER);
    string donnees;
    bool flag = false;
    Produit produit;

    while (getline(fichier, donnees, ',')) {
        if (donnees == buffer) {
            getline(fichier, donnees, ',');
            produit.compagnie = donnees;
            getline(fichier, donnees, ',');
            produit.objet = donnees;
            getline(fichier, donnees, ',');
            produit.commentaire = donnees;
            getline(fichier, donnees);
            produit.prix = stof(donnees);

            display_product(produit);
            flag = true; // produit trouve
        }
    }

    if (!flag) {
        display_error();
    }

    buffer = "";
    fichier.close();
}

void input_number(string& buffer) {
    char input;
    for (int i = 0; i < 6; i++) {
        input = _getch();
        if (input < 0x30 || input > 0x39) {
            i--;
        }
        else {
            cout << input;
            buffer += input;
        }
    }
}

int main() {
    setlocale(LC_ALL, "");

    string atlas = "ATLAS INFORMATIQUE";
    string code = "Code de produit : ";
    string buffer;

    cout << atlas;

    cout << endl << endl;
    cout << code;
    input_number(buffer);
    file_search(buffer);

    return 0;
}