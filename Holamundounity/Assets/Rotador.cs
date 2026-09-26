using UnityEngine;

public class Rotador : MonoBehaviour
{
    void Update()
    {
        // Rota el cubo en los ejes X, Y, Z a una velocidad constante
        transform.Rotate(new Vector3(15, 30, 45) * Time.deltaTime);
    }
}