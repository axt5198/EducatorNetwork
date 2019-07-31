let EducatorNetwork = artifacts.require('EducatorNetwork')

contract('EducatorNetwork', async accounts => {
    let instance 

    const instructor1 = accounts[0]
    const instructor2 = accounts[1]
    const student1 = accounts[2]
    const student2 = accounts[3]

    beforeEach(async () =>{
        instance = await EducatorNetwork.new()
    })

    // Test uploading a new video, followed by getting that added video and verifying params
    it("Should store two videos and checking the passed details are correct", async() =>{
        // Add a new video from instructor1
        await instance.addVideo(150, "solidity tutorial", "ipfs.com/video1", {from: instructor1})
        let result = await instance.getVideo(0)
        //console.log('Received from getVideo', result)
        assert.equal(result[0].toString(), instructor1.toString(), "Not uploaded by instructor 1")
        assert.equal(result[1].toString(), "solidity tutorial", "Doesn't match description passed")

       // Add a new video from instructor2
        await instance.addVideo(100, "react tutorial", "ipfs.com/video2", {from: instructor2})
        let result2 = await instance.getVideo(1)
        //console.log('Received from getVideo', result)
        assert.equal(result2[0].toString(), instructor2.toString(), "Not uploaded by instructor 2")
        assert.equal(result2[1].toString(), "react tutorial", "Doesn't match description passed")
    })
    
    it("Should not be able to getVideo that does not exist", async() => {
        // Transaction reverts when accessing a video that has not been initialized 
        try{
            await instance.getVideo(0)
            assert.fail()
        } catch(error){
            assert(error.toString().includes("Video does not exist"), error.toString())
        }
    })

    // Test uploading a translation for existing video
    it("Should add a translation for a specific video", async() =>{
        // Add a new video -- function sets videoId = 0
        await instance.addVideo(150, "solidity tutorial", "ipfs.com/video1", {from: instructor1})
        // Add a new translation for specified language
        await instance.addTranslation(0, 50, "spanish", "ipfs.com/translation1", {from: instructor1})

        // Get translation added above
        let result = await instance.getTranslation(0, "spanish")
        assert.equal(result[0].toString(), instructor1.toString(), "Not uploaded by instructor 1")
        assert.equal(result[1].toNumber(), 50, "Price doesn't match uploaded video")
        assert.equal(result[2], "ipfs.com/translation1", "Location doesn't match uploaded video") 
    })

    // Test param language against a list of valid languages
    it("Should not be able to addTranslation for invalid language", async() => {
        // Add a new video -- function sets videoId = 0
        await instance.addVideo(150, "solidity tutorial", "ipfs.com/video1", {from: instructor1})
        // Transaction reverts when language is not in list of valid languages
        try{
            await instance.addTranslation(0, 50, "spain", "ipfs.com/translation1", {from: instructor1})
            assert.fail()
        } catch(error){
            assert(error.toString().includes("Not a valid translation language"), error.toString())
        }
    })

    it("Should not be able to addTranslation for nonexisting video", async() => {
        // Transaction reverts when accessing a video that has not been initialized 
        try{
            await instance.addTranslation(0, 50, "spanish", "ipfs.com/translation1", {from: instructor1})
            assert.fail()
        } catch(error){
            assert(error.toString().includes("Video does not exist"), error.toString())
        }
    })
    
    // Test purchase video function and checking that uploader got paid correct amount
    it("Student1 should be able to purchase video uploaded by instructor1", async() =>{
        // Add a new video -- function sets videoId = 0
        await instance.addVideo(150, "solidity tutorial", "ipfs.com/video1", {from: instructor1})

        // Calculate instructor1's balance 
        let balanceBefore = (await web3.eth.getBalance(instructor1)).toString()
        //console.log('balance before', balanceBefore)

        // Student1 purchases video
        await instance.purchaseVideo(0, {from: student1, value: 150})

        // Calculate instructor1's balance after his course was purchased
        let balanceAfter = (await web3.eth.getBalance(instructor1)).toString()
        //console.log('balance after', balanceAfter)

        // Check to see that instructor1 was paid for his course
        let result = await instance.getVideo(0)
        let price = result[2].toNumber()
        assert.equal(Number(balanceBefore) + price, Number(balanceAfter), "Instructor 1 was not paid")

        // Check to see if student1 purchased video
        let didPurchaseVideo = await instance.didPurchaseVideo(0, {from: student1})
        assert.equal(didPurchaseVideo, true, "Student has not purchased this video")
    })

    it("Student1 fails to purchase video because invalid videoId", async() => {
        try{
            // Student1 tries to purchase non-existing video
            await instance.purchaseVideo(0, {from: student1, value: 10})
        } catch(error){
            assert(error.toString().includes("Video does not exist"), error.toString())
        }
    })

    // Test to avoid double paying for a video
    it("Student1 should not have to pay for a video twice", async() => {
        // Add a new video -- function sets videoId = 0
        await instance.addVideo(150, "solidity tutorial", "ipfs.com/video1", {from: instructor1})

        // Student1 purchases video
        await instance.purchaseVideo(0, {from: student1, value: 150})

        try{
            // Student1 tries to purchase video again
            await instance.purchaseVideo(0, {from: student1, value: 150})
        } catch(error){
            assert(error.toString().includes("You've already purchased this video!"), error.toString())
        }
    })

    it("Student1 fails to purchase video because of insufficient funds passed", async() =>{
        // Add a new video -- function sets videoId = 0
        await instance.addVideo(150, "solidity tutorial", "ipfs.com/video1", {from: instructor1})
        
        try{
            // Student1 tries to purchase video with value less than price
            await instance.purchaseVideo(0, {from: student1, value: 10})
        } catch(error){
            assert(error.toString().includes("Not enough funds"), error.toString())
        }

        // Check to see if student1 purchased video
        let result = await instance.didPurchaseVideo(0, {from: student1})
        assert.equal(result, false, "Student has not purchased this video")
    })

    // Test translation upload for existing video and check translator was paid correct amount
    it("Instructor2 should be able to upload a translation for video uploaded by instructor1", async() =>{
        // Instructor1 adds a new video -- function sets videoId = 0
        await instance.addVideo(150, "solidity tutorial", "ipfs.com/video1", {from: instructor1})

        // Instructor2 uploads a translation
        await instance.addTranslation(0, 50, "Spanish", "ipfs.com/translation1", {from: instructor2})

        // Student2 purchases video
        await instance.purchaseVideo(0, {from: student2, value: 150})

        // Calculate instructor2's balance 
        let balanceBefore = (await web3.eth.getBalance(instructor2)).toString()

        // Student2 purchases translation
        await instance.purchaseTranslation(0, "Spanish", {from: student2, value: 50})

        // Calculate instructor2's balance after his translation was purchased
        let balanceAfter = (await web3.eth.getBalance(instructor2)).toString()

        // Check to see that instructor2 was paid for his translation
        let result = await instance.getTranslation(0, "Spanish")
        let price = result[1].toNumber()
        assert.equal(Number(balanceBefore) + price, Number(balanceAfter), "Instructor 1 was not paid")

        // Check to see if student2 purchased translation
        let didPurchaseTranslation = await instance.didPurchaseTranslation(0, "Spanish", {from: student2})
        assert.equal(didPurchaseTranslation, true, "Student has not purchased this translation")
    })

    it("Instructor 2 should not be able to upload a translation for non-existing video", async() =>{
        try{
            // Instructor2 uploads a translation
            await instance.addTranslation(0, 50, "Spanish", "ipfs.com/translation1",{from: instructor2})
        } catch(error){   
            assert(error.toString().includes("Video does not exist"), error.toString())
        }
    })

    // Verifies person purchasing translation has purchased video
    it("Student1 fails to purchase translation because he hasn't purchase video", async() =>{
        // Add a new video -- function sets videoId = 0
        await instance.addVideo(150, "solidity tutorial", "ipfs.com/video1", {from: instructor1})
        
        // Check to see if student1 purchased video
        let result = await instance.didPurchaseVideo(0, {from: student1})
        assert.equal(result, false, "Student has purchased this video")

        try{
            // Student1 tries to purchase translation for video he hasn't purchased
            await instance.purchaseTranslation(0, "Spanish", {from: student1, value: 10})
        } catch(error){
            assert(error.toString().includes("You have not purchased the corresponding video"), error.toString())
        }
    })

    // Test purchasing non-existing translation
    it("Student1 fails to purchase translation because there isn't one yet", async() =>{
        // Add a new video -- function sets videoId = 0
        await instance.addVideo(150, "solidity tutorial", "ipfs.com/video1", {from: instructor1})

        // Student1 purchases video 
        await instance.purchaseVideo(0, {from: student1, value: 150})

        // Check to see if student1 purchased video
        let result = await instance.didPurchaseVideo(0, {from: student1})
        assert.equal(result, true, "Student has not purchased this video")
        
        try{
            // Student1 tries to purchase translation that doesn't exist
            await instance.purchaseTranslation(0, "Spanish", {from: student1, value: 10})
        } catch(error){
            assert(error.toString().includes("No translation for that language yet."), error.toString())
        }
    })

    // Test to avoid double paying for a translation
    it("Student1 should not have to pay for a translation twice", async() => {
        // Add a new video -- function sets videoId = 0
        await instance.addVideo(150, "solidity tutorial", "ipfs.com/video1", {from: instructor1})

        // Instructor2 uploads a translation
        await instance.addTranslation(0, 50, "Spanish", "ipfs.com/translation1", {from: instructor2})

        // Student1 purchases video
        await instance.purchaseVideo(0, {from: student1, value: 150})

        // Student1purchases translation
        await instance.purchaseTranslation(0, "Spanish", {from: student1, value: 50})

        try{
            // Student1 tries to purchase translation again
            await instance.purchaseVideo(0, {from: student1, value: 50})
        } catch(error){
            assert(error.toString().includes("You've already purchased this video!"), error.toString())
        }
    })

    it("Student1 fails to purchase translation because of insufficient funds passed", async() =>{
        // Add a new video -- function sets videoId = 0
        await instance.addVideo(150, "solidity tutorial", "ipfs.com/video1", {from: instructor1})

        // Instructor2 uploads a translation
        await instance.addTranslation(0, 50, "Spanish", "ipfs.com/translation1", {from: instructor2})

        // Student1 purchases video
        await instance.purchaseVideo(0, {from: student1, value: 150})
        
        try{
            // Student1 tries to purchase translation with value less than price
            await instance.purchaseTranslation(0, "Spanish", {from: student1, value: 10})
        } catch(error){
            assert(error.toString().includes("Not enough funds"), error.toString())
        }

        // Check to see if student1 purchased video
        let result = await instance.didPurchaseTranslation(0, "Spanish", {from: student1})
        assert.equal(result, false, "Student has not purchased this video")
    })
})