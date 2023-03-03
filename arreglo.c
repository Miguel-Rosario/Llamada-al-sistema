#define SIZE 5
int funcion(int arr[], int tam){
	int i;
	for(i=0;i<SIZE;i++){
		arr[i]= 5;
	}
    return i;
}

int main(){
	int i;
	int arr[SIZE];
	i = funcion(arr, SIZE);
	return 0;
}
