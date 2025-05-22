package org.example.bootcontainercompose.controller;


import lombok.RequiredArgsConstructor;
import org.example.bootcontainercompose.entity.Pet;
import org.example.bootcontainercompose.repository.PetRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/pet")
@RequiredArgsConstructor
public class PetController {
    private final PetRepository petRepository;

    @GetMapping
    public ResponseEntity<List<Pet>> getPet() {
        return ResponseEntity.ok(petRepository.findAll());
    }

    @PostMapping
    public ResponseEntity<Pet> savePet(@RequestBody Pet pet) {
        return ResponseEntity.status(201).body(petRepository.save(pet));
    }
}
