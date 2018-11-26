using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SEM : MonoBehaviour {

    public Texture t;
    Renderer r;

    void Start() {
        r = GetComponent<Renderer>();
        r.material.SetTexture("_MainTex", t);
    }
}
